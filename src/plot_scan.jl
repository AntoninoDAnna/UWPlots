function _plot_scan(par, W, pval, orient::Vertical;
		    dataLabels = [L"p_%$(i)" for i in eachindex(par[1])],
		    fitLabels = nothing,
		    fitAxisLabel = "fits",
		    plot_kw...)
    ndata = length(W)
    npar = length(par[1])
    _,imax = findmax(W)
    fig,ax = subplots(1,npar+2,sharey=true,constrained_layout=true, gridspec_kw=Dict("hspace"=>0.2))
    for (x,p) in pairs(par), (idx, pp) in pairs(p)
	uwerr(pp)
	if x != imax
	    Plots.plot_data(ax[idx],pp,x; plot_kw...)
	    continue;
	end
	ax[idx].set_xlabel(dataLabels[idx])
	ax[idx].set_xlim(pp.mean-3pp.err, pp.mean+3pp.err)
	ax[idx].axvspan(pp.mean-pp.err, pp.mean+pp.err,color="royalblue", alpha=0.5)
	Plots.plot_data(ax[idx], pp, x, c="r",m="o")
    end
    ax[1].set_ylabel(fitAxisLabel)
    __set_tickslabels(ax[1],Yaxis(),fitLabels)
    ax[end-1].barh(eachindex(pval),pval,color="royalblue")
    ax[end-1].set_xlabel("p-val")
    ax[end].barh(eachindex(W),W,color="royalblue")
    ax[end].set_xlim(0, maximum(W)*1.1)
    ax[end].set_xlabel(L"W")
    return fig,ax
end

function _plot_scan(par, pval, orient::Vertical;
		    dataLabels = [L"p_%$(i)" for i in eachindex(par[1])],
		    fitLabels = nothing,
		    fitAxisLabel = "fits",
		    plot_kw...)
    ndata = length(par)
    npar = length(par[1])
    fig,ax = subplots(1,npar+1,sharey=true,
		      constrained_layout=true,
		      gridspec_kw=Dict("hspace"=>0.2))
    for (x,p) in pairs(par), (idx, pp) in pairs(p)
	uwerr(pp)
	Plots.plot_data(ax[idx],pp,x; plot_kw...)
    end
    for (a,l) in zip(ax,dataLabels)
	a.set_xlabel(l)
    end
    ax[1].set_ylabel(fitAxisLabel)
    __set_tickslabels(ax[1],Yaxis(),fitLabels)
    ax[end].barh(eachindex(pval),pval,color="royalblue")
    ax[end].set_xlabel("p-val")
    return fig,ax
end


function __prepare_data_for_scan_plot(scan,
				      weight::Function,
				      tol::Float64,
				      parConstraint::Function,
				      parTrans::Function)
    _, _, (pval,W,aux) = utils.find_best_scan(scan, weight, tol=tol,
					      parConstraint=parConstraint,
					      data=true)
    idx = let x = findlast(cumsum(sort(W,rev=true)).<0.99)
	isnothing(x) ? lastindex(W) : x
    end
    filter =  sortperm(W,rev=true)[1:idx] |> sort!
    W = W[filter]
    pval = pval[filter]
    aux = aux[filter]
    par = parTrans.(getfield.(scan[aux],:par))
    return par,W,pval,aux
end

function __prepare_data_for_scan_plot(scan, tol::Float64,
				      parConstraint::Function,
				      parTrans::Function)
    _, _, (pval,_,aux) = utils.find_best_scan(
	scan, x->1.0, tol=tol, parConstraint=parConstraint,
	data=true)
    par = parTrans.(getfield.(scan[aux],:par))
    return par,pval,aux
end

function plot_scan(scan, weight::Function; orient=Vertical(),
		   tol::Float64 = 0.05, parConstraint::Function = x->true,
		   fitLabels=nothing,fitLabelFunc =nothing,
		   parTrans::Function=identity, plot_kw...)
    par,W,pval,aux = __prepare_data_for_scan_plot(scan,weight,tol,parConstraint, parTrans)
    if isnothing(fitLabels) && !isnothing(fitLabelFunc)
	fitLabels = [fitLabelFunc(scan[i])  for i in aux]
    end
    return _plot_scan(par,W,pval,orient;fitLabels = fitLabels,plot_kw...)
end

function plot_scan(scan; orient=Vertical(),
		   tol::Float64 = 0.05, parConstraint::Function = x->true,
		   fitLabels=nothing,fitLabelFunc =nothing,
		   parTrans::Function=identity, plot_kw...)
    par,pval,aux = __prepare_data_for_scan_plot(scan,tol,parConstraint, parTrans)
    if isnothing(fitLabels) && !isnothing(fitLabelFunc)
	fitLabels = [fitLabelFunc(scan[i])  for i in aux]
    end
    return _plot_scan(par,pval,orient;fitLabels = fitLabels,plot_kw...)
end
