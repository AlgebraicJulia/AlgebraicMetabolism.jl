""" Some description of ths package
"""
module AlgebraicMetabolism

using Catlab
using Catlab.ACSets
using Catlab.CategoricalAlgebra

export draw_subobject, is_subobject,
 SchMetabolicNet, SchReactionMetabolicNet, 
 AbstractMetabolicNet, AbstractReactionMetabolicNet,
 ReactionMetabolicNet

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

using Catlab.Graphics
using Catlab.Graphics.Graphviz

const GRAPH_ATTRS = Dict(:rankdir=>"LR")
const NODE_ATTRS = Dict(:shape => "plain", :style=>"filled")
const EDGE_ATTRS = Dict(:splines=>"splines")

Graphics.to_graphviz(m::AbstractMetabolicNet; kw...) =
  to_graphviz(to_graphviz_property_graph(m; kw...))

function Graphics.to_graphviz_property_graph(m::AbstractMetabolicNet;
  prog::AbstractString="dot", graph_attrs::AbstractDict=Dict(),
  node_attrs::AbstractDict=Dict(), edge_attrs::AbstractDict=Dict(), name::AbstractString="G", kw...)
  pg = PropertyGraph{Any}(; name = name, prog = prog,
    graph = merge!(GRAPH_ATTRS, graph_attrs),
    node = merge!(NODE_ATTRS, node_attrs),
    edge = merge!(EDGE_ATTRS, edge_attrs),
  )
  vtx = map(parts(m, :V)) do v
    γ = m[v,:γ]
    vname = m[v,:vname]
    add_vertex!(pg; label="$(vname)[$γ]", shape="circle", color="#6C9AC3")
  end

  for e in parts(m, :E₁)
    src, tgt = m[e, :src₁], m[e, :tgt₁]
    μ = m[e, :μ]
    add_edge!(pg, src, tgt, label="$(μ)")
  end

  for e in parts(m, :E₂)
    src, tgt = m[e, :src₂], m[e, :tgt₂]
    f = m[e, :f]
    add_edge!(pg, src, tgt, label="$(f)", constraint="false", style="dotted")
  end
  pg
end


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

end

using AlgebraicMetabolism
using Catlab
using Catlab.ACSets
using Catlab.CategoricalAlgebra
using Catlab.CategoricalAlgebra.CSets
using Catlab.Graphics
using Catlab.Graphics.Graphviz
using Test

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

to_graphviz(M)

X1 = Subobject(M, V=[1]) 
X2 = Subobject(M, V=[2]) 
X3 = Subobject(M, V=[3]) 




@testset "Subobject Biheyting Algebra" begin
  draw_subobject(Subobject(M, V=[1,2]))
  @test nparts(dom(hom(Subobject(M, V=[1,2]))), :V) == 2
  draw_subobject(X2)
  negate(X3) |> draw_subobject
  negate(X1) |> draw_subobject

  meet(negate(X3), negate(X1)) |> draw_subobject
  join(negate(X3), negate(X1)) |> draw_subobject

  @test dom(hom(join(negate(X3), negate(X1)))) == M

  # these should be equal by value but not by identity
  @test meet(negate(X3), negate(X1)) != X2
  # you have to force them first to convert to the same internal storage type
  @test force((meet(negate(X3), negate(X1)))) == force(X2)

  @test is_subobject(X3, negate(join(X1, X2)))

  @test force(meet(X3, negate(X1))) == force(X3)
  @test dom(hom(negate(meet(X1, X2)))) == M
end