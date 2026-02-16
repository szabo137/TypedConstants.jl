# TypedConstants

[![Stable Documentation](https://img.shields.io/badge/docs-stable-blue.svg)](https://szabo137.github.io/TypedConstants.jl/stable)
[![Development documentation](https://img.shields.io/badge/docs-dev-blue.svg)](https://szabo137.github.io/TypedConstants.jl/dev)
[![Test workflow status](https://github.com/szabo137/TypedConstants.jl/actions/workflows/Test.yml/badge.svg?branch=main)](https://github.com/szabo137/TypedConstants.jl/actions/workflows/Test.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/szabo137/TypedConstants.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/szabo137/TypedConstants.jl)
[![Docs workflow Status](https://github.com/szabo137/TypedConstants.jl/actions/workflows/Docs.yml/badge.svg?branch=main)](https://github.com/szabo137/TypedConstants.jl/actions/workflows/Docs.yml?query=branch%3Amain)
[![BestieTemplate](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/JuliaBesties/BestieTemplate.jl/main/docs/src/assets/badge.json)](https://github.com/JuliaBesties/BestieTemplate.jl)

A Julia package for defining typed constants with automatic precision conversion. This combines the benefits of `PhysicalConstants.jl` (distinct types for each constant, avoiding type piracy) with `Base.@irrational` (implicit type casting to different floating-point precisions).

## Features

- **Type Safety**: Each constant has its own unique type, preventing type piracy
- **Automatic Precision Conversion**: Constants automatically convert to `Float16`, `Float32`, `Float64`, or `BigFloat` as needed
- **Implicit Casting**: Works seamlessly in type-annotated assignments and function calls
- **Common Supertype**: All constants derive from `AbstractTypedConstant` for unified handling

## Installation

```julia
# For now, just include the file
include("TypedConstants.jl")
using .TypedConstants
```

## Basic Usage

Define a typed constant using the `@typed_const` macro:

```julia
@typed_const MyConst myconst big"1.234567890123456789012345678901234567890"
```

This creates:

1. A new type `MyConst <: AbstractTypedConstant`
2. A constant instance `myconst` of type `MyConst`
3. Automatic conversion methods to all floating-point types

## Examples

### Automatic Precision Conversion

```julia
@typed_const MyConst myconst big"1.234567890123456789012345678901234567890"

# Explicit conversion
Float16(myconst)  # 1.234
Float32(myconst)  # 1.23456789f0
Float64(myconst)  # 1.2345678901234567
BigFloat(myconst) # 1.23456789012345678901234567890123456789

# Implicit conversion in assignments
x::Float64 = myconst  # Automatically converts to Float64
y::Float32 = myconst  # Automatically converts to Float32
```

### Arithmetic Operations

```julia
# Operations preserve appropriate precision
2.0 * myconst          # 2.4691357802469134 (Float64)
Float32(2.0) * myconst # → 6.283185307179586 (Float32)
```

## Implementation Details

The `@typed_const` macro generates:

1. **Singleton Type**: A struct that subtypes `AbstractTypedConstant`
2. **High-Precision Storage**: A `BigFloat` constant with the reference value
3. **Conversion Methods**: Methods for converting to `Float16`, `Float32`, `Float64`, and `BigFloat`
4. **Promotion Rules**: Rules for type promotion in mixed operations
5. **Arithmetic Operators**: Standard arithmetic operations that preserve precision
6. **Comparison Operators**: Standard comparison operations
7. **Display Methods**: Pretty printing of the constant

## Comparison with Alternatives

| Feature                        | TypedConstants.jl | Base.@irrational | PhysicalConstants.jl |
| ------------------------------ | ----------------- | ---------------- | -------------------- |
| Automatic precision conversion | ✅                | ✅               | ❌                  |
| Type-safe (no piracy)          | ✅                | ❌               | ✅                  |
| Custom types per constant      | ✅                | ❌               | ✅                  |
| Common supertype               | ✅                | ✅ (Irrational)  | ✅                  |
| Implicit casting               | ✅                | ✅               | ❌                  |

## License

[MIT](LICENSE) © Uwe Hernandez Acosta
