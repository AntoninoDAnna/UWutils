# UWutils

Utility functions for `ADerrors` [link](https://igit.ific.uv.es/alramos/aderrors.jl).

Since both `ADerrors` and `UWutils` are not on the General Registry, you can install this package following

``` julia
(@v1.13) pkg> add https://igit.ific.uv.es/alramos/bdio.jl
(@v1.13) pkg> add https://igit.ific.uv.es/alramos/aderrors.jl
(@v1.13) pkg> add https://igit.ific.uv.es/antonino.danna.estudiante.uam.es/uwutils.git
```
# Fuctions provided
  * Overload for commonly used `Base` method like: `Base.length`, `Base.iterator`, `Base.getindex`, `Base.abs`, `Base.abs2`, `Base.zero(::Type{uwreal})`
	* `format_uwreal(x::uwreal)` return two string, `mean` and `err`, such that `$mean($err)` correctly represent  `x`.
	* `format_uwreal(x::AbstractArray{uwreal})` as above, but this the output strings have the same precision for all elements.
``` julia
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

* `uwreal_to_tuple(x::Vector{uwrea}[, idset....])` return a tuple of `Float64` where the first element is the mean value of x, while the second is the error. If `idset` is given, the second errors collects the error contribution *NOT* in `idset`, from the third error onwards, it collects the error contribution in each `idset`. `idset` can be single ensemble ids (either their `String` id or their numeric id), or collection of ids.
