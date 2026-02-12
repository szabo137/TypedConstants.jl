using TypedConstants
using Test

@testset "TypedConstants.jl" begin
    @test TypedConstants.hello_world() == "Hello, World!"
end
