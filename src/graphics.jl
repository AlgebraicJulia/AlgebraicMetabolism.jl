using Catlab
using Catlab.CategoricalAlgebra
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
