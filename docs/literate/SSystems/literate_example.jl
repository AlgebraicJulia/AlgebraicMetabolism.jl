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

# The first step is to understand the data model of what an S-System model is
#
# There are sets:
#
#  1. V the vertices, which represent variables in the system
#  2. E₁ the edges that represent positive effects
#  3. E₂ the edges that represent negative effects
#  4. Names for using human readable variable names
#  5. Numbers for storing coefficients and exponents
#
# Then there are relationships:
#  1. src₁,tgt₁ for encoding a graph of positive effects
#  2. src₂,tgt₂ for encoding a graph of negative effects
#  3. g,h tell you the numeric value associated with the exponent of that edge
#  4. α,β are intrinsic parameters for the strength of effects per vertex
#  5. vname gives you the vertex names
#
# We did not name the edges, because they don't really have conceptual identities
# other than "the interaction between x,y" where x is the src and y is the target variables.

to_graphviz(SchSystem)

# The schema definition is given in the following domain specific language (DSL) invented by Catlab.
# 
# ```julia
# @present SchMetabolicNet(FreeSchema) begin
#   (V, E₁, E₂)::Ob
#   src₁::Hom(E₁, V)
#   tgt₁::Hom(E₁, V)
# 
#   src₂::Hom(E₂, V)
#   tgt₂::Hom(E₂, V)
# end
# 
# @present SchSystem <: SchMetabolicNet begin
#   Name::AttrType
# 
#   vname::Attr(V, Name)
# 
#   Number::AttrType
#   α::Attr(V, Number)
#   β::Attr(V, Number)
# 
#   g::Attr(E₁, Number)
#   h::Attr(E₂, Number)
# end
# ```
#

# Once we define the schema, Catlab will generate a domain specific language for specifying models.
# This language isn't the easiest to write, but it is completely generated from the specification of the schema,
# and works for any type of model that you can build.

#Let's make our first model

M = @acset System{Rational} begin
  V = 3
  E₁ = 2
  E₂ = 3
  vname = [:x₁, :x₂, :x₃]
  α = [1//2, 1//2, 2]
  β = [1//3, 1//5, 2//5]

  src₁ = [1,2]
  tgt₁ = [2,3]
  g = [7,11]

  src₂ = [1,2,3]
  tgt₂ = [2,3,3]
  h = [1,2,3]
end

# We should visually inspect our model with graphviz rendering

to_graphviz(M)

# We can compute the dynamics equation from the model with `dynamics_expr`

dynamics_expr(M)

# Because these models are defined as a presheaf category, they come with 
# a lattice of subobjects. This works like subsets of a set, but will respect
# the connectivity structure of the model.

X1 = Subobject(M, V=[1]) 
X2 = Subobject(M, V=[2]) 
X3 = Subobject(M, V=[3]) 

draw_subobject(join(join(X1, X2), X3))

# From the isolate vertices shown above we can compute the "model complement"
# with the negation operator. For example, the complement of X3 is 
# X1 and X2 and all their interactions.

negate(X3) |> draw_subobject

# And the complement of X1 is X2 and X3 with all their interactions.

negate(X1) |> draw_subobject

# The meet and join operators play the role of union and intersection

meet(negate(X3), negate(X1)) |> draw_subobject

# But I always forget which is which!

join(negate(X3), negate(X1)) |> draw_subobject

# Most of your propositional logic rules apply in this lattice.

is_subobject(X3, negate(join(X1, X2)))

# The biggest difference is that double negation is not the identity.
# While join(X1,X2) has 2 vertices and no edges,
# ¬¬(X1 ∨ X2) has 2 vertices and 2 edges!
# Double negation can be used to define the "induced subgraph" operator
# for any class of models.

negate(negate(join(X1, X2))) |> draw_subobject