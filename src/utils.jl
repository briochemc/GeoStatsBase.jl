# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    readgeotable(args; coordnames=[:x,:y,:z], kwargs)

Read data from disk using `CSV.read`, optionally specifying
the columns `coordnames` with spatial coordinates.

The arguments `args` and keyword arguments `kwargs` are
forwarded to the `CSV.read` function, please check their
documentation for more details.

This function returns a [`GeoDataFrame`](@ref) object.
"""
readgeotable(args...; coordnames=[:x,:y,:z], kwargs...) =
  GeoDataFrame(read(args...; kwargs...), coordnames)

"""
    split(object, fraction, [direction])

Split spatial `object` into two parts where the first
part has a `fraction` of the total volume. The split
is performed along a `direction`. The default direction
is aligned with the first spatial dimension of the object.
"""
Base.split(object::AbstractSpatialObject{T,N}, fraction::Real,
           normal=ntuple(i -> i == 1 ? one(T) : zero(T), N)) where {N,T} =
  partition(object, BisectFractionPartitioner(normal, fraction))

"""
    groupby(sdata, var)

Partition spatial data `sdata` into groups of constant value
for spatial variable `var`.

### Notes

Missing values are grouped into a separate group.
"""
groupby(sdata::AbstractData, var::Symbol) =
  partition(sdata, VariablePartitioner(var))

"""
    boundbox(object)

Return the minimum axis-aligned bounding rectangle of the spatial `object`.

### Notes

Equivalent to `cover(object, RectangleCoverer())`
"""
boundbox(object::AbstractSpatialObject) = cover(object, RectangleCoverer())

"""
    sample(object, nsamples, [weights], replace=false)

Generate `nsamples` samples from spatial `object`
uniformly or using `weights`, with or without
replacement depending on `replace` option.
"""
function sample(object::AbstractSpatialObject, nsamples::Int,
                weights::AbstractVector=[]; replace=false)
  if isempty(weights)
    sample(object, UniformSampler(nsamples, replace))
  else
    sample(object, WeightedSampler(nsamples, weights, replace))
  end
end

"""
    join(sdata₁, sdata₂)

Join variables in spatial data `sdata₁` and `sdata₂`.
"""
Base.join(sdata₁::AbstractData, sdata₂::AbstractData) =
  join(sdata₁, sdata₂, VariableJoiner())

"""
    uniquecoords(sdata; aggreg=Dict(),
                 metric=Euclidean(), tol=1e-6)

Filter spatial data `sdata` to produce a new data
set with unique coordinates.

See [`UniqueCoordsFilter`](@ref) for more details.
"""
function uniquecoords(sdata::AbstractData; aggreg=Dict(),
                      metric=Euclidean(), tol=1e-6)
  filt = UniqueCoordsFilter(aggreg=aggreg, metric=metric, tol=tol)
  filter(sdata, filt)
end
