using Catlab
using Catlab.CategoricalAlgebra
using Catlab.Graphics
using Catlab.Graphics.Graphviz

const GRAPH_ATTRS = Dict(:rankdir=>"LR")
const NODE_ATTRS = Dict(:shape => "plain", :style=>"filled")
const EDGE_ATTRS = Dict(:splines=>"splines")

Graphics.to_graphviz(m::AbstractGMANet; kw...) =
  to_graphviz(to_graphviz_property_graph(m; kw...))

function Graphics.to_graphviz_property_graph(m::AbstractGMANet;
  prog::AbstractString="dot", graph_attrs::AbstractDict=Dict(),
  node_attrs::AbstractDict=Dict(), edge_attrs::AbstractDict=Dict(), name::AbstractString="G", kw...)
  pg = PropertyGraph{Any}(; name = name, prog = prog,
    graph = merge!(GRAPH_ATTRS, graph_attrs),
    node = merge!(NODE_ATTRS, node_attrs),
    edge = merge!(EDGE_ATTRS, edge_attrs),
  )
  vtxd = Dict(map(parts(m, :Vd)) do v
    vname = m[v,:vdname]
    v => add_vertex!(pg; label="$(vname)", shape="circle", color="#6C9AC3")
  end)
  vtxi = Dict(map(parts(m, :Vi)) do v
    vname = m[v,:viname]
    v => add_vertex!(pg; label="$(vname)", shape="circle", color="#6C9AC3")
  end)
  E1 = Dict(map(parts(m, :E₁)) do v
    γ = m[v,:γ]
    vname = Symbol("E1_$(v)")
    v => add_vertex!(pg; label="$(vname)[$γ]", shape="square", color="#E28F41")
  end)
  E2 = Dict(map(parts(m, :E₂)) do v
    μ = m[v,:μ]
    vname = Symbol("E2_$(v)")
    v => add_vertex!(pg; label="$(vname)[$μ]", shape="square", color="#a8dcd9")
  end)

  edges = Dict{Tuple{Int,Int}, Int}()
  map(parts(m, :E₁)) do e
    edge = (E1[e], vtxd[m[e, :tgt₁]])
    edges[edge] = get(edges, edge, 0) + 1
  end
  map(parts(m, :E₂)) do e
    edge = (E2[e], vtxd[m[e, :tgt₂]])
    edges[edge] = get(edges, edge, 0) + 1
  end
  map(parts(m, :I1d)) do i
    edge = (vtxd[m[i, :in₁d]], E1[m[i, :medge₁d]])
    edges[edge] = get(edges, edge, 0) + 1
  end
  map(parts(m, :I1i)) do i
    edge = (vtxi[m[i, :in₁i]], E1[m[i, :medge₁i]])
    edges[edge] = get(edges, edge, 0) + 1
  end
  map(parts(m, :I2d)) do i
    edge = (vtxd[m[i, :in₂d]], E2[m[i, :medge₂d]])
    edges[edge] = get(edges, edge, 0) + 1
  end
  map(parts(m, :I2i)) do i
    edge = (vtxi[m[i, :in₂i]], E2[m[i, :medge₂i]])
    edges[edge] = get(edges, edge, 0) + 1
  end
  for ((src, tgt),count) in edges
    add_edge!(pg, src, tgt, label="$(count)")
  end
  
  #=
  for e in parts(m, :E₂)
    src, tgt = m[e, :src₂], m[e, :tgt₂]
    h = m[e, :h]
    add_edge!(pg, src, tgt, label="$(h)", constraint="false", style="dotted")
  end
  =#
  #=
  map(parts(pn, :O)) do o
    edge = (T_vtx[pn[o, :ot]], S_vtx[pn[o, :os]])
    edges[edge] = get(edges, edge, 0) + 1
  end
  =#

  pg
end
