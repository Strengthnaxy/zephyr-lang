# Zephyr

[![CI](https://github.com/Strengthnaxy/zephyr-lang/actions/workflows/ci.yml/badge.svg)](https://github.com/Strengthnaxy/zephyr-lang/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-0.1.0-informational.svg)](VERSION)

Zephyr is a statically typed, non-mainstream systems language. It is designed as a simpler and safer alternative to C++ while keeping native performance.

Zephyr does not have its own machine-code backend. It transpiles to C++17 and relies on a mature compiler (GCC or Clang) to produce native binaries. This gives a reliable guarantee: if the generated C++ compiles, Zephyr works.

## Repository Layout

    zephyr-lang/
    ├── .github/        CI, issue and PR templates
    ├── zig/            Compiler (lexer, parser, C++ codegen)
    ├── rust/           Windows installer
    ├── cpp/            Runtime header for generated code
    ├── php/            Project landing page
    ├── ocaml/          Reference AST specification
    └── ruby/           Local build helper

## Quick Start

1. Install Zig 0.13.0 or newer.
2. Build the compiler:

       cd zig
       zig build -Doptimize=ReleaseFast

3. Create `hello.zph`:

       fn main() -> i32 {
           let msg: string = "Hello from Zephyr";
           print(msg);
           return 0;
       }

4. Compile and run:

       ./zig-out/bin/zephyr hello.zph -o hello
       ./hello

## Installation

### Windows

    cd rust
    cargo build --release
    ./target/release/zephyr-installer.exe

The installer copies the compiler to `%LOCALAPPDATA%\Zephyr` and prints instructions to add that directory to `PATH`.

### Linux (portable tarball)

    tar -xzf zephyr-lang-0.1.0-linux-x86_64.tar.gz
    cd zephyr-lang-0.1.0
    ./install.sh

`install.sh` copies `bin/zephyr` to `~/.local/bin` and prints a `PATH` reminder.

## Language Overview

Types: `i32`, `i64`, `f64`, `bool`, `string`, `void`.

Statements: `let` (immutable), `var` (mutable), `return`, `print`, expression statement.

Functions: `fn name() -> Type { ... }`.

No exceptions, no operator overloading, no hidden control flow.

## Building the Compiler

Requirements:

- Zig 0.13.0+
- A C++17 compiler (`g++` or `clang++`) in `PATH`

Build:

    cd zig
    zig build -Doptimize=ReleaseFast

## Auxiliary Components

- `cpp/runtime.hpp` — runtime header linked into generated C++.
- `php/index.php` — static landing page; serve with `php -S localhost:8000 -t php`.
- `ocaml/zephyr_ast.ml` — reference AST for cross-checking parser changes.
- `ruby/build.rb` — local helper: builds the compiler and compiles examples. Run with `ruby ruby/build.rb`.

## Contributing

See `.github/PULL_REQUEST_TEMPLATE.md`. Update `CHANGELOG.md` under `[Unreleased]` for any user-facing change.

## License

MIT. See [LICENSE](LICENSE).
