""" Some description of ths package
"""
module GMA

using Catlab
using Catlab.ACSets
using Catlab.CategoricalAlgebra
using MLStyle

# export SchSystem, AbstractGMANet, System

@present SchGMANet(FreeSchema) begin
  (Vd, Vi, E₁, E₂, I1d, I1i, I2d, I2i)::Ob
  tgt₁::Hom(E₁, Vd)
  tgt₂::Hom(E₂, Vd)
  in₁d ::Hom(I1d, Vd)
  in₁i ::Hom(I1i, Vi)
  in₂d ::Hom(I2d, Vd)
  in₂i ::Hom(I2i, Vi)
  medge₁d::Hom(I1d, E₁)
  medge₁i::Hom(I1i, E₁)
  medge₂d::Hom(I2d, E₂)
  medge₂i::Hom(I2i, E₂)
end

@present SchReactionGMANet <: SchGMANet begin
  Name::AttrType
  
  vdname::Attr(Vd, Name)
  viname::Attr(Vi, Name)

  Number::AttrType
  f₁d::Attr(I1d, Number)
  f₁i::Attr(I1i, Number)
  f₂d::Attr(I2d, Number)
  f₂i::Attr(I2i, Number)
  γ::Attr(E₁, Number)
  μ::Attr(E₂, Number)
end

@abstract_acset_type AbstractGMANet
@abstract_acset_type AbstractReactionGMANet <: AbstractGMANet

@acset_type GMANet(SchGMANet, index=[]) <: AbstractGMANet
@acset_type ReactionGMANetUntyped(SchReactionGMANet, index=[]) <: AbstractReactionGMANet


"""   GMASys{R} 

The main entry type for building a metabolic model with fixed parameters baked in.
"""
const GMASys{R} = ReactionGMANetUntyped{Symbol, R}

null_attrs(::Type{T}, m::GMANet) where T <: AbstractGMANet = begin
  M = ReactionGMANetUntyped{Symbol,Any}() 
  copy_parts!(M,m)
  return M
end

default_attrs(::Type{T}, m::GMANet) where T <: AbstractGMANet = begin
  M = null_attrs(T, m)
  
  γ::Attr(E₁, Number)
  μ::Attr(E₂, Number)

  M[:vdname] = map(parts(m,:Vd)) do v
    Symbol("Xd$v")
  end
  M[:viname] = map(parts(m,:Vi)) do v
    Symbol("Xi$v")
  end
  M[:f₁d] = map(parts(M,:I1d)) do i
    Symbol("f₁d$i")
  end
  M[:f₁i] = map(parts(M,:I1i)) do i
    Symbol("f₁i$i")
  end
  M[:f₂d] = map(parts(M,:I2d)) do i
    Symbol("f₂d$i")
  end
  M[:f₂i] = map(parts(M,:I2i)) do i
    Symbol("f₂i$i")
  end
  M[:γ] = map(parts(M,:E₁)) do e
    Symbol("γ$e")
  end
  M[:μ] = map(parts(M,:E₂)) do e
    Symbol("μ$e")
  end

  return M
end

#=
"""    edges₁(m::AbstractGMANet, i::Int, j::Int)

access a vector of the E₁ edges between vertex i and vertex j.
"""
edges₁(m::AbstractGMANet, i::Int, j::Int) = intersect(
  incident(m, i, :src₁),
  incident(m, j, :tgt₁)
)

"""    edges₂(m::AbstractGMANet, i::Int, j::Int)

access a vector of the E₂ edges between vertex i and vertex j.
"""
edges₂(m::AbstractGMANet, i::Int, j::Int) = intersect(
  incident(m, i, :src₂),
  incident(m, j, :tgt₂)
)
=#

# include("dynamics.jl")
# include("graphics.jl")
# include("composition.jl")

end