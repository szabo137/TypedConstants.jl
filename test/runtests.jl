using Test
using TypedConstants

# Define some typed constants
@typed_const Pi π big"3.1415926535897932384626433832795028841971693993751"
@typed_const E ℯ big"2.7182818284590452353602874713526624977572470936999"
@typed_const GoldenRatio φ big"1.6180339887498948482045868343656381177203091798057"


@testset "Type hierarchy" begin
    @test π isa AbstractTypedConstant
    @test typeof(π) == Pi
    @test π isa Real
    @test typeof(π) <: AbstractTypedConstant
end

@testset "Conversions" begin
    @test Float64(π) == 3.141592653589793
    @test Float32(π) == 3.1415927f0
    @test Float16(π) == Float16(3.14)
    @test BigFloat(π) > Float64(π)  # BigFloat has more precision
end

@testset "Implicit conversion" begin
    x64::Float64 = π
    @test x64 isa Float64
    @test x64 == 3.141592653589793
    
    x32::Float32 = π
    @test x32 isa Float32
    @test x32 == 3.1415927f0
    
    x16::Float16 = π
    @test x16 isa Float16
    @test x16 == Float16(3.14)
end

@testset "Arithmetic" begin
    @test isapprox(π + 1.0, 4.141592653589793)
    @test isapprox(π - 1.0, 2.141592653589793)
    @test isapprox(2.0 * π, 6.283185307179586)
    @test isapprox(π / 2.0, 1.5707963267948966)

    @test isapprox(π + ℯ, BigFloat(π) + BigFloat(ℯ))
    @test isapprox(π - ℯ, BigFloat(π) - BigFloat(ℯ))
    @test isapprox(π * ℯ, BigFloat(π) * BigFloat(ℯ))
    @test isapprox(π / ℯ, BigFloat(π) / BigFloat(ℯ))

    @test isapprox(-π, -3.141592653589793)
    @test isapprox(+π, +3.141592653589793)
end

@testset "Mixed operations" begin
    result = 2 * π
    @test result isa Float64
    @test isapprox(result,6.283185307179586)

    result = Float64(2.0) * π
    @test result isa Float64
    @test isapprox(result,6.283185307179586)

    result = Float32(2.0) * π
    @test result isa Float32
    @test isapprox(result,6.2831855f0)
    
    result = Float16(2.0) * π
    @test result isa Float16
    @test isapprox(result,Float16(6.28))
    
    result = π * 2 
    @test result isa Float64
    @test isapprox(result,6.283185307179586)

    result = π * Float64(2.0)
    @test result isa Float64
    @test isapprox(result,6.283185307179586)

    result = π * Float32(2.0)
    @test result isa Float32
    @test isapprox(result,6.2831855f0)
    
    result = π * Float16(2.0) 
    @test result isa Float16
    @test isapprox(result,Float16(6.28))
end

@testset "Comparisons" begin
    @test π > 3.0
    @test π < 4.0
    @test ℯ < π
    
    @test π >= 3.0
    @test π <= 4.0
    @test ℯ <= π
end

@testset "math functions" begin
    @test isapprox(sin(π), 0.0, atol = eps())
    @test isapprox(cos(π), -1.0)
    @test isapprox(tan(π), 0.0, atol = eps())
end

@testset "Golden ratio identity" begin
    @test abs(φ^2 - φ - 1) < 1e-10
end

