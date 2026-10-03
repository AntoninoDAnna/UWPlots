module UWPlots

using PyPlot, PyCall
using ADerrors
using EnumClasses
using Printf

include("cyclers.jl")
include("PyPlot_wrappers.jl")
include("plot_data.jl")
include("plot_gamma.jl")
include("plot_function.jl")
include("plot_scan.jl")

function __init__()
    cycler = PyCall.pyimport("cycler").cycler
    PyPlot.rc("axes",
                  prop_cycle = cycler(
                      color = ["#0173B2", "#DE8F05", "#029E73", "#D55E00", "#CC78BC", "#CA9161", "#FBAFE4", "#949494", "#ECE133", "#56B4E9"]))
    PyPlot.rc("text",usetex=true)
    PyPlot.rc("font", family="serif",serif = "Computer Modern",size=14)
    PyPlot.rc("text.latex", preamble = "\\usepackage{amsmath} \\usepackage{amssymb}")
    global MPL_AXES = PyCall.pyimport("matplotlib.axes").Axes
end

end
