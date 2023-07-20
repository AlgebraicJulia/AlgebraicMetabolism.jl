using AlgebraicMetabolism
using AlgebraicMetabolism.SSystems
using Catlab
using Catlab.ACSets
using Catlab.CategoricalAlgebra
using Catlab.CategoricalAlgebra.CSets
using Catlab.Graphics
using Catlab.Graphics.Graphviz
using Test


M = @acset GMASys{Rational} begin
  Vd = 3
  Vi = 1
  E₁ = 3
  E₂ = 4
  I1d = 3
  I1i = 1
  I2d = 4
  I2i = 0
  vdname = [:x₁, :x₂, :x₃]
  viname = [:z₁]
  γ = [4//5, 3//5, 7//11]
  μ = [1//2, 1//3, 1//7, 2//9]
  
  tgt₁ = [1,2,3]
  tgt₂ = [1,1,2,3]
  
  in₁d = [2,1,1]
  in₁i = [1]
  in₂d = [1,1,2,3]
  in₂i = []
  medge₁d = [1,2,3]
  medge₁i = [1]
  medge₂d = [1,2,3,4]
  medge₂i = []
  
  f₁d = [1,2,3]
  f₁i = [4]
  f₂d = [5,6,7,8]
  f₂i = []
end


M = @acset GMASys{Rational} begin
  Vd = 3
  Vi = 2
  E₁ = 1
  E₂ = 3
  I1d = 1 
  I1i = 1
  I2d = 2
  I2i = 3
  vdname = [:x₁, :x₂, :x₃]
  viname = [:z₁, :z₂]
  γ = [4//5]
  μ = [1//2, 1//3, 7]

  tgt₁ = [3]
  tgt₂ = [2,3,1]
  
  in₁d = [2]
  in₁i = [1]
  in₂d = [1,3]
  in₂i = [2,2,1]
  medge₁d = [1]
  medge₁i = [1]
  medge₂d = [1,3]
  medge₂i = [1,2,3]
  
  f₁d = [1]
  f₁i = [2]
  f₂d = [3,4]
  f₂i = [5,6,7]
end

display(M)

#=
@show SSystems.dynamics_expr(M)
@show map(parts(M,:V)) do i
  SSystems.dynamics_expr(M, i)
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
  α = [:α1,:α2,:α3]
  β = [:β1,:β2,:β3]
  g = [Symbol("g1,2"), Symbol("g2,3")]
  h = [Symbol("h1,2"), Symbol("h2,3"), Symbol("h3,3")]
  Mₘ  = default_attrs(System, m)
  @test Mₘ[:,:vname] == vname
  @test Mₘ[:,:α] == α
  @test Mₘ[:,:β] == β
  @test Mₘ[:,:g] == g
  @test Mₘ[:,:h] == h
end

=#