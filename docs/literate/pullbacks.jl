# # Stratification
#
# First we want to load our package with `using`, we will also want some Catlab utilities.

using AlgebraicMetabolism
using Catlab
using Catlab.ACSets
using Catlab.CategoricalAlgebra
using Catlab.CategoricalAlgebra.CSets
using Catlab.Graphics
using Catlab.Graphics.Graphviz
using Test

#Let's make our first model

M = @acset ReactionMetabolicNet{Rational} begin
  V = 3
  E₁ = 2
  E₂ = 3
  vname = [:x₁, :x₂, :x₃]
  γ = [1//2, 1//3, 2]

  src₁ = [1,2]
  tgt₁ = [2,3]
  μ = [7,11]

  src₂ = [1,2,3]
  tgt₂ = [2,3,3]
  f = [1,2,3]
end

# We should visually inspect our model with graphviz rendering

to_graphviz(M)

#Let's make our first model



@acset_type MetabolicNet(SchMetabolicNet, index=[]) <: AbstractMetabolicNet


M = @acset MetabolicNet begin
  V = 2
  E₁ = 3
  E₂ = 3

  src₁ = [1,2,1]
  tgt₁ = [1,2,2]

  src₂ = [1,2,1]
  tgt₂ = [1,2,2]
end

M² = product(M,M) |> apex

P = ReactionMetabolicNet{Rational}()
copy_parts!(P, M²)

to_graphviz(P)