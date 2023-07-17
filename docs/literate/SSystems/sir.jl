# # S-System Module Demo
#
# First we want to load our package with `using`, we will also want some Catlab utilities.

using AlgebraicMetabolism
using AlgebraicMetabolism.SSystems
using Catlab
using Catlab.ACSets
using Catlab.CategoricalAlgebra
using Catlab.CategoricalAlgebra.CSets
using Catlab.Graphics
using Catlab.Graphics.Graphviz
using Test

#Let's make our first model

M = @acset System{Rational} begin
  V = 3
  E₁ = 3
  E₂ = 3
  vname = [:S, :I, :R]
  α = [0//2, 1//3, 1//5]
  β = [1//3, 1//5, 0//5]

  src₁ = [2,2,3]
  tgt₁ = [2,1,2]
  g = [1,1,1]

  src₂ = [1,1,2]
  tgt₂ = [1,2,2]
  h = [1,1,1]
end

# We should visually inspect our model with graphviz rendering

to_graphviz(M)

# We can compute the dynamics equation from the model with `dynamics_expr`

dynamics_expr(M)