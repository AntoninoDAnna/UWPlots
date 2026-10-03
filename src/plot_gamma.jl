using Format
@doc raw"""
     format_uwreal(x::uwreal)
     format_uwreal(x::AbstractArray{uwreal})

Assumes `uwerr` has been run on `x`. It return a tuple or a vector of tuples in which the first entry is the central value of `x` and the second is the error rounded to the last significant digit

# Example
```jldoctest
  julia> using ADerros, Format
  julia> x = uwreal([0.1934583,0.003],"test")
  0.1934583 (Error not available... maybe run uwerr)

  julia> uwerr(x)

  julia>  (v,e) = format_uwreal(x)
  ("0.193", "3")

  julia>  println("$v($e)");
  0.193(3)

  julia> y = [uwreal([1.03 ,0.044325],"test2"),uwreal([0.455,0.005425],"test3")]
  2-element Vector{uwreal}:
   1.03 (Error not available... maybe run uwerr)
   0.455 (Error not available... maybe run uwerr)

  julia> uwerr.(y)
  2-element Vector{Nothing}:
   nothing
   nothing

  julia> (v1,e1),(v2,e2) = format_uwreal(y)
  2-element Vector{Tuple{String, String}}:
   ("1.030", "44")
   ("0.455", "5")

  julia> println("$v1($e1)\n$v2($e2)")
  1.030(44)
  0.455(5)
```
"""
function format_uwreal(x::uwreal)
    v,e = x.mean, x.err;
    M = v==0 ? 1 : -floor(Int64,log10(0.5*e))
    v = round(v,digits=M)
    e = round(e,digits=M)
    if M<0
        e = Format.format(e,precision=0)
        v = Format.format(v,precision= 0)
    else
        e = Format.format(e*10. ^M,precision=0)
        v = Format.format(v,precision=M)
    end
    return v,e
end

function format_uwreal(x::AbstractArray{uwreal})
    v,e = value.(x), ADerrors.err.(x);
    M = -floor.(Int64,log10.(0.5.*e)) |> maximum
    v = round.(v,digits=M)
    e = round.(e,digits=M)
    if M<0
        e = Format.format.(e,precision=0)
        v = Format.format.(v,precision= 0)
    else
        e = Format.format.(e.*10. ^M,precision=0)
        v = Format.format.(v,precision=M)
    end
    return collect(zip(v,e))
end

function plot_gamma(a::uwreal,id::String)
    fig,ax = subplots(1)
    r = rho(a,id)
    dr = drho(a,id)
    iw = window(a,id)
    τ = taui(a,id)
    dτ = dtaui(a,id)
    x = eachindex(r).-1
    ax.errorbar(x,r,dr;get_plot_parameters()...)
    ax.set_ylabel(L"\rho(t)")
    ax.set_xlabel("MonteCarlo time")
    _t = @sprintf( "\$ %s(%s)\$", format_uwreal(a)...)
    ax.text(0.85,0.85,_t,transform=ax.transAxes,va = "bottom", ha="right")
    ax.axhline(0.0,ls="--",color="k")
    xmax = max(100,iw*3)
    ax.set_xlim(-1,xmax)
    ax.axvline(iw,c="r")
    return fig,ax
end
