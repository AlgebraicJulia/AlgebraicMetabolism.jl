using Catlab
using Catlab.CategoricalAlgebra
using Catlab.Graphics
using Catlab.Graphics.Graphviz

const GRAPH_ATTRS = Dict(:rankdir=>"LR")
const NODE_ATTRS = Dict(:shape => "plain", :style=>"filled")
const EDGE_ATTRS = Dict(:splines=>"splines")

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
    add_vertex!(pg; label="$(vname)", shape="circle", color="#6C9AC3")
  end)
  vtxi = Dict(map(parts(m, :Vi)) do v
    vname = m[v,:vname]
    add_vertex!(pg; label="$(vname)", shape="circle", color="#6C9AC3")
  end)
  E1 = Dict(map(parts(m, :E₁)) do v
    γ = m[v,:γ]
    μ = m[v,:μ]
    vname = m[v,:vname]
    add_vertex!(pg; label="$(vname)[$γ:$μ]", shape="square", color="#E28F41")
  end)
  E2 = Dict(map(parts(m, :E₂)) do v
    γ = m[v,:γ]
    μ = m[v,:μ]
    vname = m[v,:vname]
    add_vertex!(pg; label="$(vname)[$γ:$μ]", shape="square", color="#E28F41")
  end)

  edges = Dict{Tuple{Int,Int}, Int}()
  map(parts(m, :E₁)) do e
    edge = (E1[m[e, :E₁]], vtxd[m[e, :tgt₁]])
    edges[edge] = get(edges, edge, 0) + 1
  end
  map(parts(m, :E₂)) do e
    edge = (E2[m[e, :E₂]], vtxd[m[e, :tgt₂]])
    edges[edge] = get(edges, edge, 0) + 1
  end
  map(parts(m, :I1d)) do i
    edge = (vtxd[m[i, :ind₁d]], E1[m[i, :medge₁d]])
    edges[edge] = get(edges, edge, 0) + 1
  end
  map(parts(m, :I1i)) do i
    edge = (vtxi[m[i, :ind₁i]], E1[m[i, :medge₁i]])
    edges[edge] = get(edges, edge, 0) + 1
  end
  map(parts(m, :I2d)) do i
    edge = (vtxd[m[i, :ind₂d]], E2[m[i, :medge₂d]])
    edges[edge] = get(edges, edge, 0) + 1
  end
  map(parts(m, :I2i)) do i
    edge = (vtxi[m[i, :ind₂i]], E2[m[i, :medge₂i]])
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

#=
  tgt₁::Hom(E₁, Vd)
  tgt₂::Hom(E₂, Vd)
  in₁d ::Hom(Id, Vd)
  in₁i ::Hom(Ii, Vi)
  in₂d ::Hom(Id, Vd)
  in₂i ::Hom(Ii, Vi)
  medge₁d::Hom(Id, E₁)
  medge₁i::Hom(Ii, E₁)
  medge₂d::Hom(Id, E₂)
  medge₂i::Hom(Ii, E₂)
=#


#=
using Catlab, Catlab.Graphics.Graphviz
using Catlab.Graphics.Graphviz: Graph

import Catlab.Graphics.Graphviz: Subgraph
import Catlab.Graphics: to_graphviz, to_graphviz_property_graph

const GRAPH_ATTRS = Dict(:rankdir=>"LR")
const NODE_ATTRS = Dict(:shape => "plain", :style=>"filled")
const EDGE_ATTRS = Dict(:splines=>"splines")


# Single Petri Nets
###################

to_graphviz(pn::Union{
              AbstractPetriNet,
              Subobject{<:AbstractPetriNet},
              StructuredMulticospan{<:StructuredCospans.AbstractDiscreteACSet{<:AbstractPetriNet}},
            }; kw...) =
  to_graphviz(to_graphviz_property_graph(pn; kw...))

function to_graphviz_property_graph(pn::AbstractPetriNet;
    prog::AbstractString="dot", graph_attrs::AbstractDict=Dict(),
    node_attrs::AbstractDict=Dict(), edge_attrs::AbstractDict=Dict(), name::AbstractString="G", kw...)
  pg = PropertyGraph{Any}(; name = name, prog = prog,
    graph = merge!(GRAPH_ATTRS, graph_attrs),
    node = merge!(NODE_ATTRS, node_attrs),
    edge = merge!(EDGE_ATTRS, edge_attrs),
  )
  S_vtx = Dict(map(parts(pn, :S)) do s
    s => add_vertex!(pg; label="$(sname(pn, s))", shape="circle", color="#6C9AC3")
  end)
  T_vtx = Dict(map(parts(pn, :T)) do t
    t => add_vertex!(pg; label="$(tname(pn, t))", shape="square", color="#E28F41")
  end)

  edges = Dict{Tuple{Int,Int}, Int}()
  map(parts(pn, :I)) do i
    edge = (S_vtx[pn[i, :is]], T_vtx[pn[i, :it]])
    edges[edge] = get(edges, edge, 0) + 1
  end
  map(parts(pn, :O)) do o
    edge = (T_vtx[pn[o, :ot]], S_vtx[pn[o, :os]])
    edges[edge] = get(edges, edge, 0) + 1
  end
  for ((src, tgt),count) in edges
    add_edge!(pg, src, tgt, label="$(count)")
  end

  pg
end


=#