using AlgebraicMetabolism
using Catlab
using Catlab.ACSets
using Catlab.CategoricalAlgebra
using Catlab.CategoricalAlgebra.CSets
using Catlab.Graphics
using Catlab.Graphics.Graphviz
using Catlab.Programs
using Catlab.Programs.RelationalPrograms
using Test

M = @acset MetabolicNet begin
  V = 2
  E₁ = 3
  E₂ = 3

  src₁ = [1,2,1]
  tgt₁ = [1,2,2]

  src₂ = [1,2,1]
  tgt₂ = [1,2,2]
end

Mₒ = OpenMetabolicNet(M,FinFunction([1],2),FinFunction([2],2));

d = @relation (x,z) begin
  f(x,y)
  g(y,z)
end

M₂ = oapply(d,[Mₒ,Mₒ])

@test nparts(apex(M₂), :V) == 3
@test nparts(apex(M₂), :E₁) == 6
@test nparts(apex(M₂), :E₂) == 6

Mₒꜛ = OpenMetabolicNet(M, FinFunction([2],2), FinFunction([1],2))
M₂ꜛ = oapply(d,[Mₒ,Mₒꜛ])

@test nparts(apex(M₂ꜛ), :V) == 3
@test nparts(apex(M₂ꜛ), :E₁) == 6
@test nparts(apex(M₂ꜛ), :E₂) == 6

M₄ = oapply(d,[M₂ꜛ, Mₒ])
@test nparts(apex(M₄), :V) == 4
@test nparts(apex(M₄), :E₁) == 9
@test nparts(apex(M₄), :E₂) == 9