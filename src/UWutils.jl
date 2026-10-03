module UWutils
using ADerrors, Format

Base.length(::uwreal) = 1

function Base.iterate(uw::uwreal,state=1)
    state>length(uw) && return nothing
    return uw[state], state+1
end

function Base.getindex(uw::uwreal,ii)
    (ii>length(uw) || ii<=0) && throw(BoundsError(uw,[ii]))
    return uw
end

Base.abs(uw::uwreal) = uw.mean>0 ? uw : -uw
Base.abs2(uw::uwreal) = uw^2

Base.zero(::Type{uwreal}) = uwreal(0.0)

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
function format_uwreal(x::uwreal)::Tuple{String,String}
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

export format_uwreal

@doc raw"
    uwreal_to_tuple(x::uwreal)

Return a `Tuple{Float64,Float64}` with mean and error.
"
uwreal_to_tuple(x::uwreal) = x.mean,x.err

@doc raw"
     uwreal_to_tuple(x::uwreal,idset... )

It returns a `NTuple{N+1,Float64}` where `length(idset) = N` which contains the mean value (first element),and the errors contributing to `x` divided in set according to `idset`. The first error quoted (the second element of the resulting tuple) is a \" garbage collector\", that means it collect all the error contribution not included in `idset`. `idset` can be `Int64`, `String`, or any container whose `eltype` is and `Int64` or `String`
"
function uwreal_to_tuple(x::uwreal,idset...)

    in_set(id,set) = in_set(id,set, eltype(set))

    in_set(id::T,set::T) where T = id == set

    in_set(id::Int64,set::String) = ADerrors.wsg.str2id[set] == id

    in_set(id::String,set::Int64) = ADerrors.wsg.str2id[id] == set


    in_set(id::T,set,::Type{T}) where T = id in set

    in_set(id::Int64,set,::Type{String}) = any(id == ADerrors.wsg.str2id[s] for s in set)

    in_set(id::String,set,::Type{Int64})= ADerrors.wsg.str2id[id] in set

    err =zeros(Float64, length(idset)+1)

    for (idx,id) in enumerate(x.ids)
        flag = false
        for (sdx, sets) in enumerate(idset)
            !in_set(id,sets) && continue
            err[sdx+1] += x.cfd[idx].var
            flag= true
        end
        flag && continue
        err[1] += x.cfd[idx].var
    end
    return (x.mean,sqrt.(err)...)
end

export  uwreal_to_tuple

end # module UWutils
