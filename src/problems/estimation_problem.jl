# ------------------------------------------------------------------
# Copyright (c) 2017, Júlio Hoffimann Mendes <juliohm@stanford.edu>
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

"""
    EstimationProblem(spatialdata, domain, targetvars)

A spatial estimation problem on a given `domain` in which the
variables to be estimated are listed in `targetvars`. The
data of the problem is stored in `spatialdata`.

## Examples

Create an estimation problem for rainfall precipitation measurements:

```julia
julia> EstimationProblem(spatialdata, domain, :precipitation)
```

Create an estimation problem for precipitation and CO₂:

```julia
julia> EstimationProblem(spatialdata, domain, [:precipitation, :CO₂])
```
"""
struct EstimationProblem{S<:AbstractSpatialData,D<:AbstractDomain} <: AbstractProblem
  # input fields
  spatialdata::S
  domain::D
  targetvars::Dict{Symbol,DataType}

  # state fields
  mappings::Dict{Symbol,Dict{Int,Int}}

  function EstimationProblem{S,D}(spatialdata, domain, targetvars,
                                  mapper) where {S<:AbstractSpatialData,D<:AbstractDomain}
    probvnames = [var for (var,V) in targetvars]
    datavnames = [var for (var,V) in variables(spatialdata)]
    datacnames = [coord for (coord,T) in coordinates(spatialdata)]

    @assert !isempty(probvnames) && probvnames ⊆ datavnames "target variables must be present in spatial data"
    @assert isempty(probvnames ∩ datacnames) "target variables can't be coordinates"
    @assert ndims(domain) == length(datacnames) "data and domain must have the same number of dimensions"
    @assert coordtype(spatialdata) == coordtype(domain) "data and domain must have the same coordinate type"

    mappings = map(spatialdata, domain, probvnames, mapper)

    new(spatialdata, domain, targetvars, mappings)
  end
end

function EstimationProblem(spatialdata::S, domain::D, targetvarnames::Vector{Symbol};
                           mapper=SimpleMapper()) where {S<:AbstractSpatialData,D<:AbstractDomain}
  # build dictionary of target variables
  datavars = variables(spatialdata)
  targetvars = Dict(var => T for (var,T) in datavars if var ∈ targetvarnames)

  EstimationProblem{S,D}(spatialdata, domain, targetvars, mapper)
end

function EstimationProblem(spatialdata::S, domain::D, targetvarname::Symbol;
                           mapper=SimpleMapper()) where {S<:AbstractSpatialData,D<:AbstractDomain}
  EstimationProblem(spatialdata, domain, [targetvarname]; mapper=mapper)
end

"""
    data(problem)

Return the spatial data of the estimation `problem`.
"""
data(problem::EstimationProblem) = problem.spatialdata

"""
    domain(problem)

Return the spatial domain of the estimation `problem`.
"""
domain(problem::EstimationProblem) = problem.domain

"""
    variables(problem)

Return the variable names of the estimation `problem` and their types.
"""
variables(problem::EstimationProblem) = problem.targetvars

"""
    datamap(problem, targetvar)

Return the mapping from domain locations to data locations for the
`targetvar` of the `problem`.
"""
datamap(problem::EstimationProblem, var) = problem.mappings[var]

# ------------
# IO methods
# ------------
function Base.show(io::IO, problem::EstimationProblem)
  dim = ndims(problem.domain)
  print(io, "$(dim)D EstimationProblem")
end

function Base.show(io::IO, ::MIME"text/plain", problem::EstimationProblem)
  vars = ["$var ($T)" for (var,T) in problem.targetvars]
  println(io, problem)
  println(io, "  data:      ", problem.spatialdata)
  println(io, "  domain:    ", problem.domain)
  print(  io, "  variables: ", join(vars, ", ", " and "))
end
