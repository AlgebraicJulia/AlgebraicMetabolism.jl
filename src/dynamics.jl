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

@doc raw"""    dynamics_expr(m::ReactionMetabolicNet)

Build the expression for a reaction net from the combinatorial data.
The expression we want to build is equivalent to:

    dxi = sum(μ[i,j] ⋅ γ[j] ⋅ prod(X[k]^f[j,k] for k in 1:N) for j in 1:N)

``\frac{d}{dt} X_i = \sum_j(\mu_{i,j} \cdot \gamma_j \cdot \prod_k X_k^f_{j,k}``

This formula evaluates the dynamics of the system.
"""
function dynamics_expr(m::ReactionMetabolicNet)
  N = nparts(m, :V)
  lines = map(parts(m, :V)) do i
    dynamics_expr(m, i)
  end
  res = quote end
  append!(res.args, lines)
  return res
end