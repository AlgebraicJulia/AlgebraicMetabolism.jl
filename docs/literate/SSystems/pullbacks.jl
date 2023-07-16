# # Stratification
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


M = @acset MetabolicNet begin
  V = 2
  E₁ = 3
  E₂ = 3

  src₁ = [1,2,1]
  tgt₁ = [1,2,2]

  src₂ = [1,2,1]
  tgt₂ = [1,2,2]
end

# Now we can compute the product model to get a model with 2×2=4 states.

M² = product(M,M)
to_graphviz(default_attrs(System, apex(M²)))

# We need to propagate the attributes from the factor models to the product model.
# We start with the attributes for the original two models.

P = System{Rational}()
copy_parts!(P, apex(M²))
vnames₁ = [:x1, :x2]
α₁ = [1//2, 1//7]
β₁ = [1//3, 1//5]
g₁ = [2,3,5]
h₁ = [1,2,3]

vnames₂ = [:a, :b]
α₂ = [7//2, 7//3]
β₂ = [3//5, 2//5]
g₂ = 11*[2,3,5]
h₂ = [1,2,3]/2

# The names get composed by tupling and the coefficients multiply.

π₁, π₂ = legs(M²)
for v in parts(P, :V)
  P[v, :vname] = Symbol("($(vnames₁[π₁[:V](v)]),$(vnames₂[π₂[:V](v)]))")
  P[v, :α] = α₁[π₁[:V](v)]*α₂[π₂[:V](v)]
  P[v, :β] = β₁[π₁[:V](v)]*β₂[π₂[:V](v)]
end

# The exponents add

for e in parts(P, :E₁)
  P[e, :g] = g₁[π₁[:E₁](e)]+g₂[π₂[:E₁](e)]
end

for e in parts(P, :E₂)
  P[e, :h] = h₁[π₁[:E₂](e)]+h₂[π₂[:E₂](e)]
end

# And the resulting model can be drawn. Notice the symmetry in both the structure, and the numbers.
to_graphviz(P)