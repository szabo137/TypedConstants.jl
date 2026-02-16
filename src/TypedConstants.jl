module TypedConstants

export AbstractTypedConstant, @typed_const

"""
    AbstractTypedConstant

Abstract base type for all typed constants. Each constant defined with `@typed_const`
will have its own concrete type that subtypes this.
"""
abstract type AbstractTypedConstant <: Real end

"""
    @typed_const TypeName symbol big_value

Define a typed constant with automatic precision conversion.

# Arguments
- `TypeName`: The name of the type to create for this constant
- `symbol`: The symbol/variable name for the constant instance
- `big_value`: A BigFloat or expression that evaluates to the constant's high-precision value

# Example
```julia
@typed_const Pi π big"3.1415926535897932384626433832795028841971693993751"

# Now you can use π with automatic conversion:
x::Float64 = π  # converts to Float64
y::Float32 = π  # converts to Float32
```
"""
macro typed_const(typename, symbol, bigvalue)
    #TODO: Ensure typename and symbol are valid identifiers

    typename_str = string(typename)
    symbol_str = string(symbol)
    etypename = esc(typename)
    esymbol = esc(symbol)
    evalue = esc(bigvalue)

    return quote
        # Define the new type as a singleton
        struct $etypename <: AbstractTypedConstant end
        
        # Create the constant instance
        const $esymbol = $etypename()
        
        # Store the high-precision value
        const $(Symbol("_", symbol_str, "_bigval")) = $evalue
       
        let v = $evalue, v64 = Float64(v), v32 = Float32(v), v16 = Float16(v)
            #Base.Float16(::$etypename) = v16 
            Base.Float32(::$etypename) = v32
            Base.Float64(::$etypename) = v64 
        end
        
        Base.BigFloat(::$(esc(typename))) = $(Symbol("_", symbol_str, "_bigval"))
       
        #=
        # Support for promote_rule to enable implicit conversion
        Base.promote_rule(::Type{$etypename}, ::Type{Float16}) = Float16
        Base.promote_rule(::Type{$etypename}, ::Type{Float32}) = Float32
        Base.promote_rule(::Type{$etypename}, ::Type{Float64}) = Float64
        Base.promote_rule(::Type{$etypename}, ::Type{BigFloat}) = BigFloat
        
        # Promote typed constant to the other type in mixed operations
        Base.promote_rule(::Type{$etypename}, ::Type{T}) where {T<:AbstractFloat} = T
        =#
        
        # Convert method (used by promote)
        Base.convert(::Type{T}, ::$etypename) where {T<:AbstractFloat} = T($esymbol)
        Base.convert(::Type{$etypename}, x::$etypename) = x
        
        # Widen returns BigFloat for maximum precision
        Base.widen(::Type{$etypename}) = BigFloat
        
        # String representation
        Base.show(io::IO, ::$etypename) = print(io, $(symbol_str))
        
        # Basic arithmetic operations return appropriate precision
        # These delegate to the converted values
                
        # Hash for using in collections
        Base.hash(::$etypename, h::UInt) = hash($(Symbol("_", symbol_str, "_bigval")), h)
        
        
        nothing
    end
end

Base.promote_rule(::Type{<:AbstractTypedConstant}, ::Type{Float16}) = Float16
Base.promote_rule(::Type{<:AbstractTypedConstant}, ::Type{Float32}) = Float32
Base.promote_rule(::Type{<:AbstractTypedConstant}, ::Type{<:AbstractIrrational}) = Float64
Base.promote_rule(::Type{<:AbstractTypedConstant}, ::Type{T}) where {T<:Real} = promote_type(Float64, T)

function Base.promote_rule(::Type{S}, ::Type{T}) where {S<:AbstractTypedConstant,T<:Number}
    U = promote_type(S, real(T))
    if S <: U
        # prevent infinite recursion
        promote_type(Float64, T)
    else
        promote_type(U, T)
    end
end

# default to F64
Base.AbstractFloat(x::AbstractTypedConstant) = Float64(x)::Float64
Base.Float16(x::AbstractTypedConstant) = Float16(Float32(x)::Float32)
Base.Complex{T}(x::AbstractTypedConstant) where {T<:Real} = Complex{T}(T(x))

for op in (:+, :-, :*, :/, :^)
    @eval Base.$op(c::T, x::Real) where T <: AbstractTypedConstant = $op(promote(c, x)...)
    @eval Base.$op(x::Real, c::T) where T <: AbstractTypedConstant = $op(promote(x, c)...)
end

Base.:(^)(x::T, n::Integer) where T <: AbstractTypedConstant = Float64(x)^n

# Comparison operations
for op in (:(==), :<, :<=, :>, :>=)
    @eval Base.$op(c::T, x::Real) where T<: AbstractTypedConstant = $op(Float64(c), x)
    @eval Base.$op(x::Real, c::T) where T<: AbstractTypedConstant = $op(x, Float64(c))
    @eval Base.$op(x1::AbstractTypedConstant, x2::AbstractTypedConstant) = $op(BigFloat(x1), BigFloat(x2))
end

# Arithmetic operations between two typed constants
Base.:+(c1::AbstractTypedConstant, c2::AbstractTypedConstant) = BigFloat(c1) + BigFloat(c2)
Base.:-(c1::AbstractTypedConstant, c2::AbstractTypedConstant) = BigFloat(c1) - BigFloat(c2)
Base.:*(c1::AbstractTypedConstant, c2::AbstractTypedConstant) = BigFloat(c1) * BigFloat(c2)
Base.:/(c1::AbstractTypedConstant, c2::AbstractTypedConstant) = BigFloat(c1) / BigFloat(c2)

# Unary operations
Base.:-(c::AbstractTypedConstant) = -BigFloat(c)
Base.:+(c::AbstractTypedConstant) = c

Base.abs(c::AbstractTypedConstant) = abs(Float64(c))
Base.sign(c::AbstractTypedConstant) = c < zero(c) ?  -1.0 : 1.0

Base.zero(::AbstractTypedConstant) = false
Base.zero(::Type{<:AbstractTypedConstant}) = false

Base.one(::AbstractTypedConstant) = true
Base.one(::Type{<:AbstractTypedConstant}) = true

end
