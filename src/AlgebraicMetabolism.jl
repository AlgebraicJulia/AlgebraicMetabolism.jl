""" Some description of ths package
"""
module AlgebraicMetabolism

using Catlab
using Catlab.ACSets
using Catlab.CategoricalAlgebra

export draw_subobject, is_subobject,
 SchMetabolicNet, SchReactionMetabolicNet, 
 AbstractMetabolicNet, AbstractReactionMetabolicNet,
 MetabolicNet,
 ReactionMetabolicNet, dynamics_expr,
 null_attrs, default_attrs

draw_subobject = to_graphviz ∘ dom ∘ hom
is_subobject(X::Subobject,Y::Subobject) = force(meet(X,Y)) == force(X)

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

@acset_type MetabolicNet(SchMetabolicNet, index=[]) <: AbstractMetabolicNet
@acset_type ReactionNetUntyped(SchReactionMetabolicNet, index=[]) <: AbstractReactionMetabolicNet

"""    ReactionMetabolicNet{R} 

The main entry type for building a metabolic model with fixed parameters baked in.
"""
const ReactionMetabolicNet{R} = ReactionNetUntyped{Symbol, R}

null_attrs(m::MetabolicNet) = begin
  M = AlgebraicMetabolism.ReactionNetUntyped{Symbol,Any}() 
  copy_parts!(M,m)
  return M
end

default_attrs(m::MetabolicNet) = begin
  M = null_attrs(m)
  M[:vname] = map(parts(m,:V)) do i
    Symbol("X$i")
  end
  M[:γ] = map(parts(M,:V)) do v
    Symbol("γ$v")
  end
  M[:μ] = map(parts(M,:E₁)) do e
    s,t = M[e,:src₁],M[e,:tgt₁]
    Symbol("μ$s,$t")
  end
  M[:f] = map(parts(M,:E₂)) do e
    s,t = M[e,:src₂],M[e,:tgt₂]
    Symbol("f$s,$t")
  end

  return M
end

"""    edges₁(m::ReactionMetabolicNet, i::Int, j::Int)

access a vector of the E₁ edges between vertex i and vertex j.
"""
edges₁(m::ReactionMetabolicNet, i::Int, j::Int) = intersect(
  incident(m, i, :src₁),
  incident(m, j, :tgt₁)
)

"""    edges₂(m::ReactionMetabolicNet, i::Int, j::Int)

access a vector of the E₂ edges between vertex i and vertex j.
"""
edges₂(m::ReactionMetabolicNet, i::Int, j::Int) = intersect(
  incident(m, i, :src₂),
  incident(m, j, :tgt₂)
)

include("dynamics.jl")
include("graphics.jl")
include("composition.jl")
include("SSystems/SSystems.jl")
end