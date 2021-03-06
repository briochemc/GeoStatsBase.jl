# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    LearningSolution

A solution to a spatial estimation problem.
"""
struct LearningSolution{T,N,D<:AbstractDomain{T,N}} <: AbstractData{T,N}
  domain::D
  data::OrderedDict{Symbol,<:AbstractVector}
end

LearningSolution(domain, data) = LearningSolution{typeof(domain)}(domain, data)

# ------------
# IO methods
# ------------
function Base.show(io::IO, solution::LearningSolution)
  dim = ndims(solution.domain)
  print(io, "$(dim)D LearningSolution")
end

function Base.show(io::IO, ::MIME"text/plain", solution::LearningSolution)
  println(io, solution)
  println(io, "  domain: ", solution.domain)
  print(  io, "  variables: ", join(keys(solution.data), ", ", " and "))
end
