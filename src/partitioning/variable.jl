# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    VariablePartitioner(var)

A method for partitioning spatial data into subsets of
constant value for variable `var`.
"""
struct VariablePartitioner <: AbstractPartitioner
  var::Symbol
end

function partition(sdata::AbstractData,
                   partitioner::VariablePartitioner)
  var = partitioner.var
  svars = variables(sdata)

  @assert var ∈ keys(svars) "invalid variable name"

  # partition function with missings
  function f(i, j)
    vi, vj = sdata[i,var], sdata[j,var]
    mi, mj = ismissing(vi), ismissing(vj)
    (mi && mj) || ((!mi && !mj) && (vi == vj))
  end

  # partition function without missings
  g(i, j) = sdata[i,var] == sdata[j,var]

  # select the appropriate function
  h = Missing <: svars[var] ? f : g

  partition(sdata, FunctionPartitioner(h))
end
