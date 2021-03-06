# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    LearnedModel(model, θ)

An object that stores `model` together with learned parameters `θ`.
"""
struct LearnedModel
  model
  θ
end

"""
    learn(task, geodata, model)

Learn the `task` with `geodata` using a learning `model`.
"""
function learn(task::AbstractLearningTask, geodata::AbstractData, model)
  if issupervised(task)
    X = view(geodata, collect(features(task)))
    y = vec(geodata[label(task)])
    θ, _, __ = MI.fit(model, 0, X, y)
  else
    X = view(geodata, collect(features(task)))
    θ, _, __ = MI.fit(model, 0, X)
  end

  LearnedModel(model, θ)
end

function learn(task::CompositeTask, geodata::AbstractData, model)
  @error "not implemented"
end

"""
    perform(task, geodata, lmodel)

Perform the `task` with `geodata` using a *learned* `lmodel`.
"""
function perform(task::AbstractLearningTask, geodata::AbstractData, lmodel::LearnedModel)
  # unpack model and learned parameters
  model, θ = lmodel.model, lmodel.θ

  # apply model to the data
  X = view(geodata, collect(features(task)))
  ŷ = MI.predict(model, θ, X)

  # post-process result
  var = outputvars(task)[1]
  if issupervised(task)
    result = isprobabilistic(model) ? mode.(ŷ) : ŷ
  else
    result = ŷ
  end

  OrderedDict(var => result)
end

function perform(task::CompositeTask, geodata::AbstractData, lmodel::LearnedModel)
  @error "not implemented"
end
