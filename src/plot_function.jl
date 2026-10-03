function _fill_between(ax::PyObj, xdata::AbstractVector{<:Real}, ydata::AbstractVector{uwreal}; wpm = Dict{Int64,Vector{Float64}}(), kw...)
    [uwerr(y,wpm) for y in ydata]
    y,dy = value.(ydata), err.(ydata)
    ax.fill_between(xdata,y.+dy, y.-dy;
                    get_plot_parameters(kw,fillbetween_sym)...)
end

_fill_between(ax::PyObj, xdata::AbstractVector{<:Real}, ydata::AbstractVector{<:Real}; wpm = Dict{Int64,Vector{Float64}}(), kw...) =
    __unsafe_plot_data(ax::PyObj,xdata,ydata; kw..., linestyle="-", marker="")

__unsafe_plot_function(ax::PyObj, xdata::AbstractVector, F::Function; k...) = __fill_between(ax,xdata,F(xdata); kw...)

__unsafe_plot_function(ax::PyObj, xdata, ydata; kw...) = _fill_between(ax::PyObj, xdata, ydata; kw...)

@doc raw"""
    plot_function([ax::PyObj],F::Function, xdata::AbstractVector{<:Real}, kw...)                         (1)
    plot_function([ax::PyObj],xdata::AbstractVector{<:Real}, ydata::AbstractVector{uwreal}; wpm, kw...)  (2)
    plot_function([ax::PyObj],xdata::AbstractVector{<:Real}, ydata::AbstractVector{<:Real};kw...)        (3)

Plot the function `F(xdata)` on `ax`. `ax` must be a valid `Axes` object according to `PyCall.pyisinstance`. If `ax` is not provided, `PyPlot.gca()` is called.
 - (1): Evaluate the function `F(xdata)` and plot the output by calling either (2) or (3).
 - (2): Plot `ydata` vs `xdata` using `PyPlot.fill_between`, with the error in `ydata`, computed using `wpm`, to define the band
 - (3): Plot `ydata` vs `xdata` using `PyPlot.plot`
"""
function plot_function(ax::PyObj,a,b; kw...)
    validate_pyobs(ax, MPL_AXES)
    __unsafe_plot_function(ax,a,b; kw...)
end

plot_function(a,b;kw...) = __unsafe_plot_function(gca(),a,b; kw...)
