""" Some description of ths package
"""
module AlgebraicMetabolism

using Catlab
using Catlab.ACSets
using Catlab.CategoricalAlgebra


""" ACSet definition for a Biochemical Systems Theory model

See Catlab.jl documentation for description of the @present syntax.
"""
@present SchMetabolicNet(FreeSchema) begin
  (V, E₁, E₂)::Ob
  src₁::Hom(E₁, V)
  tgt₁::Hom(E₁, V)

  src₂::Hom(E₂, V)
  tgt₂::Hom(E₂, V)
end

@present SchReactionMetabolicNet <: SchMetabolicNet begin
  Name::AttrType

  vname::Attr(V, Name)

  Number::AttrType
  γ::Attr(V, Number)
  μ::Attr(E₁, Number)
  f::Attr(E₂, Number)

end

@abstract_acset_type AbstractMetabolicNet
@abstract_acset_type AbstractReactionMetabolicNet <: AbstractMetabolicNet

@acset_type ReactionNetUntyped(SchReactionMetabolicNet, index=[]) <: AbstractReactionMetabolicNet

const ReactionMetabolicNet{R} = ReactionNetUntyped{Symbol, R}

edges₁(m::ReactionMetabolicNet, i::Int, j::Int) = intersect(
  incident(m, i, :src₁),
  incident(m, j, :tgt₁)
)

edges₂(m::ReactionMetabolicNet, i::Int, j::Int) = intersect(
  incident(m, i, :src₂),
  incident(m, j, :tgt₂)
)

# const OpenLabelledReactionNetObUntyped, OpenLabelledReactionNetUntyped = OpenACSetTypes(LabelledReactionNetUntyped, :S)
# const OpenLabelledReactionNetOb{R,C} = OpenLabelledReactionNetObUntyped{R,C,Symbol}
# const OpenLabelledReactionNet{R,C} = OpenLabelledReactionNetUntyped{R,C,Symbol}

function Base.Expr(m::ReactionMetabolicNet, i::Int)
  N = nparts(m, :V)
  xi = m[i, :V]
  :(
    d$xi = sum(μ[$i,j] ⋅ γ[j] ⋅ prod(X[k]^f[j,k] for k in 1:N) for j in 1:N)
  )
end

function Base.Expr(m::ReactionMetabolicNet, i::Int, j::Int, k::Int)
  edges = edges₂(m, j,k)
  if length(edges) == 0
    1
  else
    f = sum(m[edges, :f])
    xk = m[k, :vname]
    :(($xk)^$f)
  end
end


function Base.Expr(m::ReactionMetabolicNet, i::Int, j::Int)
  e = edges₁(m, i, j)
  μ = sum(m[e, :μ])
  γ = m[j, :γ]
  factors = map(parts(m,:V)) do k
    Expr(m, i,j,k)
  end
  :(*($μ, $(factors...)))
end


function Base.Expr(m::ReactionMetabolicNet, i::Int)
  summands = map(parts(m,:V)) do j
    Expr(m, i,j)
  end
  xi = m[i,:vname]
  :(d.$xi = +($(summands...)))
end

function Base.Expr(m::ReactionMetabolicNet)
  N = nparts(m, :V)
  lines = map(parts(m, :V)) do i
    Expr(m, i)
  end
  res = quote end
  append!(res.args, lines)
  return res
end

M = @acset ReactionMetabolicNet{Float64} begin
  V = 3
  E₁ = 2
  E₂ = 3
  vname = [:x₁, :x₂, :x₃]
  γ = [1/2, 1/3, 2]

  src₁ = [1,2]
  tgt₁ = [2,3]
  μ = [7,11]

  src₂ = [1,2,3]
  tgt₂ = [2,3,3]
  f = [1,2,3]
end

end

using Catlab
using Catlab.ACSets
using Catlab.CategoricalAlgebra

M = AlgebraicMetabolism.M
display(M)

@show Expr(M)
@show Expr(M, 1,2,3)
@show map(parts(M,:V)) do j
  Expr(M, 1,j)
end

@show map(parts(M,:V)) do i
  Expr(M, i)
end