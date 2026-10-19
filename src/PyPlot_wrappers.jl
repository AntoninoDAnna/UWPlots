## symbol accepted by PyPlot, no more that one alias allowed
@enumclass PlotSymbols color marker linestyle fillstyle capsize alpha zorder label facecolors markerfacecolor

const alias_symbols = Dict(PlotSymbols.color  => (:c, :color),
                           PlotSymbols.marker => (:m, :marker),
                           PlotSymbols.linestyle => (:ls, :linestyle),
                           PlotSymbols.fillstyle => (:fs, :fillstyle),
                           PlotSymbols.markerfacecolor=>(:mfc, :markerfacecolor, :fc, :facecolors),
                           PlotSymbols.capsize  => (:cs, :capsize),
                           PlotSymbols.alpha  => (:a, :alpha),
                           PlotSymbols.zorder => (:zorder,),
                           PlotSymbols.label => (:label,),
                           PlotSymbols.facecolors => (:fc,:facecolors, :mfc, :markerfacecolor))

const allowed_symbol = collect(Iterators.flatten(values(alias_symbols)))

const symbol_to_pyplot = Dict(PlotSymbols.color => :color,
                              PlotSymbols.marker => :marker,
                              PlotSymbols.linestyle => :linestyle,
                              PlotSymbols.fillstyle => :fillstyle,
                              PlotSymbols.capsize => :capsize,
                              PlotSymbols.alpha => :alpha,
                              PlotSymbols.zorder => :zorder,
                              PlotSymbols.label => :label,
                              PlotSymbols.facecolors => :facecolors,
                              PlotSymbols.markerfacecolor=> :markerfacecolor,)

const default_vals = Dict(PlotSymbols.color => nothing,
                          PlotSymbols.marker=> next_marker,
                          PlotSymbols.linestyle =>"",
                          PlotSymbols.fillstyle => "full",
                          PlotSymbols.capsize=> 5.0,
                          PlotSymbols.alpha=> 1.0,
                          PlotSymbols.zorder=> nothing,
                          PlotSymbols.label => nothing,
                          PlotSymbols.facecolors=> nothing,
                          PlotSymbols.markerfacecolor=> nothing)

const errorbar_sym = (PlotSymbols.color,
                      PlotSymbols.marker,
                      PlotSymbols.linestyle,
                      PlotSymbols.fillstyle,
                      PlotSymbols.markerfacecolor,
                      PlotSymbols.capsize,
                      PlotSymbols.alpha,
                      PlotSymbols.zorder,
                      PlotSymbols.label)

const plot_sym = (PlotSymbols.color,
                  PlotSymbols.marker,
                  PlotSymbols.linestyle,
                  PlotSymbols.fillstyle,
                  PlotSymbols.alpha,
                  PlotSymbols.zorder,
                  PlotSymbols.label)

const scatter_sym = (PlotSymbols.color,
                     PlotSymbols.marker,
                     PlotSymbols.alpha,
                     PlotSymbols.zorder,
                     PlotSymbols.label,
                     PlotSymbols.facecolors,)

const fillbetween_sym = (PlotSymbols.color,
                         PlotSymbols.alpha,
                         PlotSymbols.zorder,
                         PlotSymbols.label)

MPL_AXES = nothing
const PyObj = PyCall.PyObject

validate_pyobs(p::PyObj, type) =  pyisinstance(p,type) || throw(ArgumentError(LazyString("Expected a ",type," object")))

hassym(kw,s) = any(x->haskey(kw,x), alias_symbols[s])

__get_def__(x) = x
__get_def__(f::Function) = f()
get_default(s) = __get_def__(default_vals[s])

function getval(kw,s)
    !hassym(kw,s) && return get_default(s)
    for ss in alias_symbols[s]
        haskey(kw,ss) && return get(kw,ss,nothing)
    end
end

get_plot_parameters() = NamedTuple( symbol_to_pyplot[s] => get_default(s) for (s,_) in symbol_to_pyplot)

function is_valid(kw)
    not_allowed_keys = filter(x -> !(x in allowed_symbol), keys(kw))
    !isempty(not_allowed_keys) || (return nothing)
    _temp = string(join(not_allowed_keys," "))
    throw(error(lazy"Symbols $(_temp) not supported"))
end

function get_plot_parameters(kw, accepted)
    is_valid(kw)
    return NamedTuple(symbol_to_pyplot[s]=>getval(kw,s) for s in accepted)
end

__get_nth_par(p::AbstractVector,n) = p[n]
__get_nth_par(p,n) = p
__get_nth_par(p::NamedTuple,n) =
    (;[k=>__get_nth_par(getfield(p,k),n) for k in keys(p)]...)

function saveplot(fig,filename)
    fig.savefig(filename,
                metadata = Dict(
                    "CreationDate" => nothing,
                    "Producer" => nothing,
                    "Creator" => nothing,
                    "ModDate" => nothing))
end


function add_ax(ax;loc,functions)
    new_ax = ax.secondary_xaxis(loc,functions=functions)
    ticks = ax.get_xticks()
    new_ticks = [functions[1](t) for t in ticks]
    new_ax.set_xticks(new_ticks)
    return new_ax
end

## helpers struct to use automatic dispatch to our advantage
struct Horizontal end
struct Vertical end
struct Xaxis end
struct Yaxis end


__set_tickslabels(ax,axis::Xaxis,label) = ax.set_xticks(eachindex(label),label)
__set_tickslabels(ax,axis::Yaxis,label) = ax.set_yticks(eachindex(label),label)
__set_tickslabels(ax,axis::Xaxis,label::Union{Missing,Nothing}) = nothing
__set_tickslabels(ax,axis::Yaxis,label::Union{Missing,Nothing}) = nothing
