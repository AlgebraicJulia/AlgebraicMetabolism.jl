""" Some description of ths package
"""
module SSystems

using Catlab
using Catlab.ACSets
using Catlab.CategoricalAlgebra
using MLStyle

export draw_subobject, is_subobject,
 SchMetabolicNet, SchSystem,
 AbstractMetabolicNet, AbstractSystem,
 MetabolicNet,
 System, dynamics_expr,
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

@present SchSystem <: SchMetabolicNet begin
  Name::AttrType

  vname::Attr(V, Name)

  Number::AttrType
  α::Attr(V, Number) # activation coefficients
  β::Attr(V, Number) # repression coefficients

  g::Attr(E₁, Number) # activation exponents
  h::Attr(E₂, Number) # repression coefficients
end

@abstract_acset_type AbstractMetabolicNet
@abstract_acset_type AbstractSystem <: AbstractMetabolicNet

@acset_type MetabolicNet(SchMetabolicNet, index=[]) <: AbstractMetabolicNet
@acset_type SystemUntyped(SchSystem, index=[]) <: AbstractSystem

"""    System{R} 

The main entry type for building a metabolic model with fixed parameters baked in.
"""
const System{R} = SystemUntyped{Symbol, R}

null_attrs(m::MetabolicNet) = begin
  M = AlgebraicMetabolism.SystemUntyped{Symbol,Any}() 
  copy_parts!(M,m)
  return M
end

default_attrs(m::MetabolicNet) = begin
  M = null_attrs(m)
  M[:vname] = map(parts(m,:V)) do i
    Symbol("X$i")
  end
  M[:α] = map(parts(M,:V)) do v
    Symbol("α$v")
  end
  M[:β] = map(parts(M,:V)) do v
    Symbol("β$v")
  end
  M[:g] = map(parts(M,:E₁)) do e
    s,t = M[e,:src₁],M[e,:tgt₁]
    Symbol("g$s,$t")
  end
  M[:h] = map(parts(M,:E₂)) do e
    s,t = M[e,:src₂],M[e,:tgt₂]
    Symbol("h$s,$t")
  end

  return M
end

"""    edges₁(m::AbstractMetabolicNet, i::Int, j::Int)

access a vector of the E₁ edges between vertex i and vertex j.
"""
edges₁(m::AbstractMetabolicNet, i::Int, j::Int) = intersect(
  incident(m, i, :src₁),
  incident(m, j, :tgt₁)
)

"""    edges₂(m::AbstractMetabolicNet, i::Int, j::Int)

access a vector of the E₂ edges between vertex i and vertex j.
"""
edges₂(m::AbstractMetabolicNet, i::Int, j::Int) = intersect(
  incident(m, i, :src₂),
  incident(m, j, :tgt₂)
)

include("dynamics.jl")
include("graphics.jl")
include("composition.jl")

end