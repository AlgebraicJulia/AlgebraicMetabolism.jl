function dynamics_expr(m::System, key::Symbol, i::Int)
  factor, terms = @match key begin
    :α => begin
      αᵢ = m[i,:α]
      terms = map(parts(m, :V)) do j
        xj = m[j, :vname]
        gij = sum(m[e, :g] for e in edges₁(m, i,j); init=0)
        gij != 0 ? :($xj ^ $gij) : nothing
      end
      terms = filter!(!isnothing, terms)
      αᵢ, terms
    end
    :β => begin
      βᵢ = m[i,:β]
      terms = map(parts(m, :V)) do j
        xj = m[j, :vname]
        hij = sum(m[e, :h] for e in edges₂(m, i,j); init=0)
        hij != 0 ? :($xj ^ $hij) : nothing
      end
      terms = filter!(!isnothing, terms)
      βᵢ, terms
    end
  end
  terms = terms
  length(terms) > 0 ?
    :(*($factor, $(terms...))) :
    :($factor)
end

function dynamics_expr(m::System, i::Int)
  summands = map([:α, :β]) do key
    dynamics_expr(m, key, i)
  end
  xi = m[i,:vname]
  :(d.$xi = $(summands[1]) - $(summands[2]))
end

@doc raw"""    dynamics_expr(m::System)

Build the expression for an S-System from the combinatorial data.
The expression we want to build is equivalent to:

``\frac{d}{dt} X_i = \alpha_i \prod_j X_j^{g_{i,j}} - \beta_i\prod_j X^{h_{i,j}}

This formula evaluates the dynamics of the system.
"""
function dynamics_expr(m::System)
  lines = map(parts(m, :V)) do i
    dynamics_expr(m, i)
  end
  res = quote end
  append!(res.args, lines)
  return res
end