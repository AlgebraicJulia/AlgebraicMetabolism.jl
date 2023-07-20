# function dynamics_expr(m::System, key::Symbol, i::Int)
function dynamics_expr(m::AbstractReactionGMANet, c::Dict, e::Int, i::Int)
  terms_d = map(incident(m,e,c[:ld])) do i_d
    v = m[c[:id]][i_d]
    term = :($(m[:vdname][v]) ^ $(m[c[:fd]][i_d]))
  end
  terms_i = map(incident(m,e,c[:li])) do i_i
    v = m[c[:ii]][i_i]
    term = :($(m[:viname][v]) ^ $(m[c[:fi]][i_i]))
  end
  terms = vcat(terms_d,terms_i)
  factor = :($(m[c[:s]][e]))

  length(terms) > 0 ?
    :(*($factor, $(terms...))) :
    :($factor)
end

function dynamics_expr(m::AbstractReactionGMANet, k::Int, i::Int)
  if k==1
    cols = Dict(
    :j => :tgt₁,
    :ld => :medge₁d,
    :li => :medge₁i,
    :id => :in₁d,
    :ii => :in₁i,
    :fd => :f₁d,
    :fi => :f₁i,
    :s => :γ)
  else # k==2
    cols = Dict(:j => :tgt₂,
    :ld => :medge₂d,
    :li => :medge₂i,
    :id => :in₂d,
    :ii => :in₂i,
    :fd => :f₂d,
    :fi => :f₂i,
    :s => :μ)
  end

  summands = map(incident(m,i,cols[:j])) do e
    dynamics_expr(m, cols, e, i)
  end
end

function dynamics_expr(m::AbstractReactionGMANet, i::Int)
  summands = map([1, 2]) do key
    dynamics_expr(m, key, i)
  end
  xi = m[i,:vdname]
  #= if length(summands[1])==0
    P = :(0)
  elseif length(summands[1])>1   
    P = :(+($(summands[1]...))) 
  else 
    P = :($(summands[1]))
  end
  if length(summands[2])==0
    N = :(0)
  elseif length(summands[2])>1
    N = :(+($(summands[2]...)))
  else 
    N = :($(summands[2]))
  end =#
  :(d.$xi = +($(summands[1]...)) - +($(summands[2]...)))
  # :(d.$xi = $P - $N)
end


@doc raw"""    dynamics_expr(m::GMANet)

Build the expression for an Generalized Mass Action system from the combinatorial data.
The expression we want to build is equivalent to:

``\frac{d}{dt} X_i = \gamma_i \prod_j X_j^{g_{i,j}} - \mu_i\prod_j X^{h_{i,j}}``

This formula evaluates the dynamics of the system.
"""
function dynamics_expr(m::AbstractReactionGMANet)
  lines = map(parts(m, :Vd)) do i
    dynamics_expr(m, i)
  end
  res = quote end
  append!(res.args, lines)
  return res
end