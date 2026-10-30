# Zephyr

Zephyr is a statically typed, non-mainstream systems language. It is designed as a simpler and safer alternative to C++ while keeping native performance.

Zephyr does not have its own machine-code backend. It transpiles to C++17 and relies on a mature compiler (GCC or Clang) to produce native binaries. This gives a reliable guarantee: if the generated C++ compiles, Zephyr works.

## Repository Layout

    zephyr-lang/
    └── zig/            Compiler (lexer, parser, C++ codegen)

## Quick Start

1. Install Zig 0.17.0 or newer.
2. Build the compiler:

       cd zig
       zig build -Doptimize=ReleaseFast

3. Create `hello.zph`:

       fn main() -> i32 {
           let msg: string = "Hello world";
           print(msg);
           return 0;
       }

4. Compile and run:

       ./zig/zig-out/bin/zephyr hello.zph -o hello
       ./hello

Expected output:

    Hello world

## Language Overview

Types: `i32`, `i64`, `f64`, `bool`, `string`, `void`.

Statements: `let` (immutable), `var` (mutable), `return`, `print`, expression statement.

Functions: `fn name() -> Type { ... }`.

No exceptions, no operator overloading, no hidden control flow.

## Building the Compiler

Requirements:

- Zig 0.17.0+
- A C++17 compiler (`g++` or `clang++`) in `PATH`

Build:

    cd zig
    zig build -Doptimize=ReleaseFast

The binary is placed at `zig/zig-out/bin/zephyr`.

## Usage

    zephyr <input.zph> -o <output>

Example:

    zephyr hello.zph -o hello

Zephyr writes `<output>.cpp` next to the output binary and invokes `g++` to compile it.

## Contributing

See `.github/PULL_REQUEST_TEMPLATE.md`. Update `CHANGELOG.md` under `[Unreleased]` for any user-facing change.

## License

MIT. See LICENSE.
