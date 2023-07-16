using Catlab
using Catlab.CategoricalAlgebra
using Catlab.Graphics
using Catlab.Graphics.Graphviz

const GRAPH_ATTRS = Dict(:rankdir=>"LR")
const NODE_ATTRS = Dict(:shape => "plain", :style=>"filled")
const EDGE_ATTRS = Dict(:splines=>"splines")

function Graphics.to_graphviz_property_graph(m::AbstractSystem;
  prog::AbstractString="dot", graph_attrs::AbstractDict=Dict(),
  node_attrs::AbstractDict=Dict(), edge_attrs::AbstractDict=Dict(), name::AbstractString="G", kw...)
  pg = PropertyGraph{Any}(; name = name, prog = prog,
    graph = merge!(GRAPH_ATTRS, graph_attrs),
    node = merge!(NODE_ATTRS, node_attrs),
    edge = merge!(EDGE_ATTRS, edge_attrs),
  )
  vtx = map(parts(m, :V)) do v
    α = m[v,:α]
    β = m[v,:β]
    vname = m[v,:vname]
    add_vertex!(pg; label="$(vname)[$α:$β]", shape="circle", color="#6C9AC3")
  end

  for e in parts(m, :E₁)
    src, tgt = m[e, :src₁], m[e, :tgt₁]
    g = m[e, :g]
    add_edge!(pg, src, tgt, label="$(g)")
  end

  for e in parts(m, :E₂)
    src, tgt = m[e, :src₂], m[e, :tgt₂]
    h = m[e, :h]
    add_edge!(pg, src, tgt, label="$(h)", constraint="false", style="dotted")
  end
  pg
end
