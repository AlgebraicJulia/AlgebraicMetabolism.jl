using AlgebraicMetabolism
using Catlab
using Catlab.ACSets
using Catlab.CategoricalAlgebra
using Catlab.CategoricalAlgebra.CSets
using Catlab.Graphics
using Catlab.Graphics.Graphviz
using Test

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

display(M)

@show dynamics_expr(M)
@show dynamics_expr(M, 1,2,3)
@show map(parts(M,:V)) do j
  dynamics_expr(M, 1,j)
end

@show map(parts(M,:V)) do i
  dynamics_expr(M, i)
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


m = @acset MetabolicNet begin
  V = 3
  E₁ = 2
  E₂ = 3

  src₁ = [1,2]
  tgt₁ = [2,3]

  src₂ = [1,2,3]
  tgt₂ = [2,3,3]
end

@testset "Default Attributes" begin
  vname = [:X1, :X2, :X3]
  γ = [:γ1,:γ2,:γ3]
  μ = [Symbol("μ1,2"), Symbol("μ2,3")]
  f = [Symbol("f1,2"), Symbol("f2,3"), Symbol("f3,3")]
  Mₘ  = default_attrs(m)
  @test Mₘ[:,:vname] == vname
  @test Mₘ[:,:γ] == γ
  @test Mₘ[:,:μ] == μ
  @test Mₘ[:,:f] == f
end