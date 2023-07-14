""" Some description of ths package
"""
module AlgebraicMetabolism

using Catlab
using Catlab.ACSets
using Catlab.CategoricalAlgebra

export draw_subobject, is_subobject,
 SchMetabolicNet, SchReactionMetabolicNet, 
 AbstractMetabolicNet, AbstractReactionMetabolicNet,
 ReactionMetabolicNet, dynamics_expr

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

# function dynamics_expr(m::ReactionMetabolicNet, i::Int)
#   N = nparts(m, :V)
#   xi = m[i, :V]
#   :(
#     d$xi = sum(μ[$i,j] ⋅ γ[j] ⋅ prod(X[k]^f[j,k] for k in 1:N) for j in 1:N)
#   )
# end

function dynamics_expr(m::ReactionMetabolicNet, i::Int, j::Int, k::Int)
  edges = edges₂(m, j,k)
  if length(edges) == 0
    1
  else
    f = sum(m[edges, :f])
    xk = m[k, :vname]
    :(($xk)^$f)
  end
end


function dynamics_expr(m::ReactionMetabolicNet, i::Int, j::Int)
  e = edges₁(m, i, j)
  μ = sum(m[e, :μ])
  γ = m[j, :γ]
  factors = map(parts(m,:V)) do k
    dynamics_expr(m, i,j,k)
  end
  :(*($μ, $(factors...)))
end


function dynamics_expr(m::ReactionMetabolicNet, i::Int)
  summands = map(parts(m,:V)) do j
    dynamics_expr(m, i,j)
  end
  xi = m[i,:vname]
  :(d.$xi = +($(summands...)))
end

function dynamics_expr(m::ReactionMetabolicNet)
  N = nparts(m, :V)
  lines = map(parts(m, :V)) do i
    dynamics_expr(m, i)
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

end