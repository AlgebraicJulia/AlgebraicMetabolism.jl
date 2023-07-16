using Test

using AlgebraicMetabolism

@testset "Core" begin
  include("core.jl")
end

@testset "Composition" begin
  include("composition.jl")
end

@testset "SSystems" begin
  include("SSystems/runtests.jl")
end