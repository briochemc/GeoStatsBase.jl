# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    RegularGridData(data)
    RegularGridData(data, origin, spacing)

Regularly spaced `data` georeferenced with `origin` and `spacing`.
The `data` argument is a dictionary mapping variable names to Julia
arrays with the actual data.

`NaN` or `missing` values in the Julia arrays are interpreted as
non-valid. They can be used to mask the variables on the grid.

## Examples

Given `poro` and `perm` two 2-dimensional Julia arrays containing
values of porosity and permeability, the following code can be used
to georeference the data:

```julia
julia> data = OrderedDict(:porosity => poro, :permeability => perm)
julia> RegularGridData(data, (0.,0.,0.), (1.,1.,1.))
```

Alternatively, one can omit `origin` and `spacing` for default
values of zeros and ones:

```julia
julia> RegularGridData{Float64}(data)
```

See also: [`RegularGrid`](@ref)
"""
struct RegularGridData{T,N} <: AbstractData{T,N}
  data::OrderedDict{Symbol,<:AbstractArray}
  domain::RegularGrid{T,N}

  function RegularGridData{T,N}(data, domain) where {N,T}
    new(data, domain)
  end
end

function RegularGridData(data::OrderedDict{Symbol,<:AbstractArray},
                         origin::NTuple{N,T}, spacing::NTuple{N,T}) where {N,T}
  sizes = [size(array) for array in values(data)]
  @assert length(unique(sizes)) == 1 "data dimensions must be the same for all variables"
  @assert length(sizes[1]) == N "inconsistent number of dimensions for given origin/spacing"
  RegularGridData{T,length(origin)}(data, RegularGrid(sizes[1], origin, spacing))
end

RegularGridData{T}(data::OrderedDict{Symbol,<:AbstractArray{<:Any,N}}) where {N,T} =
  RegularGridData(data, ntuple(i->zero(T), N), ntuple(i->one(T), N))

Base.size(geodata::RegularGridData) = size(geodata.domain)
origin(geodata::RegularGridData) = origin(geodata.domain)
spacing(geodata::RegularGridData) = spacing(geodata.domain)

function Base.getindex(geodata::RegularGridData, var::Symbol)
  vals = [getindex(geodata, ind, var) for ind in 1:npoints(geodata)]
  reshape(vals, size(geodata))
end

function Base.getindex(geodata::RegularGridData,
                       icoords::Vararg{Int,N}) where {N}
  lin  = LinearIndices(size(geodata.domain))
  ind  = lin[icoords...]
  vars = [var for (var,V) in variables(geodata)]
  vals = [geodata.data[var][ind] for var in vars]
  NamedTuple{tuple(vars...)}(vals)
end

# ------------
# IO methods
# ------------
function Base.show(io::IO, geodata::RegularGridData{T,N}) where {N,T}
  dims = join(size(geodata), "×")
  print(io, "$dims RegularGridData{$T,$N}")
end

function Base.show(io::IO, ::MIME"text/plain", geodata::RegularGridData{T,N}) where {N,T}
  println(io, geodata)
  println(io, "  origin:  ", Tuple(origin(geodata)))
  println(io, "  spacing: ", Tuple(spacing(geodata)))
  println(io, "  variables")
  varlines = ["    └─$var ($(eltype(array)))" for (var, array) in geodata.data]
  print(io, join(varlines, "\n"))
end
