""" Some description of ths package
"""
module SSystems

using Catlab
using Catlab.ACSets
using Catlab.CategoricalAlgebra
using MLStyle

import ..dynamics_expr
import ..SchMetabolicNet
import ..MetabolicNet
import ..AbstractMetabolicNet
import ..null_attrs
import ..default_attrs

export SchSystem, AbstractSystem, System



@present SchSystem <: SchMetabolicNet begin
  Name::AttrType

  vname::Attr(V, Name)

  Number::AttrType
  α::Attr(V, Number) # activation coefficients
  β::Attr(V, Number) # repression coefficients

  g::Attr(E₁, Number) # activation exponents
  h::Attr(E₂, Number) # repression coefficients
end

@abstract_acset_type AbstractSystem <: AbstractMetabolicNet
@acset_type SystemUntyped(SchSystem, index=[]) <: AbstractSystem

"""    System{R} 

The main entry type for building a metabolic model with fixed parameters baked in.
"""
const System{R} = SystemUntyped{Symbol, R}

null_attrs(::Type{T}, m::MetabolicNet) where T <: AbstractSystem = begin
  M = SystemUntyped{Symbol,Any}() 
  copy_parts!(M,m)
  return M
end

default_attrs(::Type{T}, m::MetabolicNet) where T <: AbstractSystem = begin
  M = null_attrs(T, m)
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