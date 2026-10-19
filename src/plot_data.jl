function __unsafe_plot_data(ax, xdata::AbstractArray{<:Real}, ydata::AbstractArray{uwreal}; wpm=Dict{Int64, Vector{Float64}}(), kw...)
    [uwerr(y, wpm) for y in ydata]
    ax.errorbar(xdata, value.(ydata), err.(ydata); get_plot_parameters(kw, errorbar_sym)...)
end

function __unsafe_plot_data(ax::PyObj, xdata::AbstractArray{uwreal}, ydata::AbstractArray{uwreal};wpm=Dict{Int64, Vector{Float64}}(), kw...)
    [uwerr(y, wpm) for y in ydata]
    [uwerr(x, wpm) for x in xdata]
    ax.errorbar(value.(xdata), value.(ydata), err.(ydata), err.(xdata);get_plot_parameters(kw, errorbar_sym)...)
end

function __unsafe_plot_data(ax::PyObj, xdata::AbstractArray{uwreal}, ydata::AbstractArray{<:Real}, wpm=Dict{Int64, Vector{Float64}}())
    [uwerr(x, wpm) for x in xdata]
    par = get_plot_parameters(kw);
    ax.errorbar(value.(xdata), ydata, xerr = err.(xdata); get_plot_parameters(kw, errorbar_sym)...)
end

function __unsafe_plot_data(ax::PyObj, xdata::AbstractArray{<:Real}, ydata::AbstractArray{<:Real} ;wpm=Dict{Int64, Vector{Float64}}(), kw...)
    ax.scatter(xdata, ydata; get_plot_parameters(kw, scatter_sym)...)
end

function __unsafe_plot_data(ax::PyObj, xdata::Real, ydata::uwreal;wpm=Dict{Int64, Vector{Float64}}(), kw...)
    uwerr(ydata)
    ax.errorbar(xdata, ydata.mean, ydata.err; get_plot_parameters(kw, plot_sym)...)
end

function __unsafe_plot_data(ax::PyObj, xdata::uwreal, ydata::Real;wpm=Dict{Int64, Vector{Float64}}(), kw...)
    uwerr(xdata)
    ax.errorbar(xdata.mean, ydata, 0, xdata.err;
                get_plot_parameters(kw, plot_sym)...)
end

function __unsafe_plot_data(ax::PyObj, xdata::uwreal, ydata::uwreal;wpm=Dict{Int64, Vector{Float64}}(), kw...)
    uwerr(ydata)
    uwerr(xdata)
    ax.errorbar(xdata.mean, ydata.mean, ydata.err, xdata.err;
                get_plot_parameters(kw, plot_sym)...)
end

@doc raw"""
     plot_data([ax::PyCall.PyObject,] xdata, ydata; kw....)

plot the data onto `ax`. `ax` must be a valid `Axes` object according to `PyCall.pyisinstance`. If `ax` is not provided, `PyPlot.gca()` is called.
"""
function plot_data(ax::PyObj, xdata::AbstractVector{T}, ydata::AbstractVector{U}; wpm=Dict{Int64, Vector{Float64}}(), kw...) where {T,U}
    validate_pyobs(ax, MPL_AXES)
    __unsafe_plot_data(ax, xdata, ydata;wpm=wpm, kw...)
end

function plot_data(ax::PyObj, ydata::AbstractVector{T}; wpm=Dict{Int64, Vector{Float64}}(), kw...) where T
    validate_pyobs(ax, MPL_AXES)
    __unsafe_plot_data(ax::PyObj, eachindex(ydata), ydata; wpm=wpm, kw...)
end

plot_data(xdata::AbstractVector{T}, ydata::AbstractVector{U}; k...) where {T,U} = __unsafe_plot_data(gca(), xdata, ydata; k...)

plot_data(ydata::AbstractVector{T}; k...) where T = __unsafe_plot_data(gca(), eachindex(ydata), ydata; k...)

function plot_data(ax::PyObj, xdata::AbstractVector{T}, ydata::AbstractVector{U},r::Vector{UnitRange{Int64}}; kw...) where {T,U}
    validate_pyobs(ax, MPL_AXES)
    par = get_plot_parameters(kw,plot_sym)
    for (i,_r) in enumerate(r)
        p = __get_nth_par(par,i)
        __unsafe_plot_data(ax,xdata[_r],ydata[_r];p...)
    end
end
