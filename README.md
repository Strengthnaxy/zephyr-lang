# Zephyr

[![CI](https://github.com/Strengthnaxy/zephyr-lang/actions/workflows/ci.yml/badge.svg)](https://github.com/Strengthnaxy/zephyr-lang/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/badge/version-0.2.0-blue.svg)](https://github.com/Strengthnaxy/zephyr-lang/blob/main/VERSION)
[![Ruby](https://img.shields.io/badge/Ruby-3.0%2B-CC342D.svg)](https://www.ruby-lang.org/)
[![C++](https://img.shields.io/badge/C%2B%2B-17-00599C.svg)](https://isocpp.org/)

**Zephyr** is a statically typed, non-mainstream systems language. It is designed as a simpler and safer alternative to C++ while keeping native performance.

Zephyr does not have its own machine-code backend. It transpiles to C++17 and relies on a mature compiler (GCC or Clang) to produce native binaries. This gives a reliable guarantee: if the generated C++ compiles, Zephyr works.

**v0.2.0** moves the main compiler to **Ruby** (`ruby/`) and adds function parameters, arithmetic, comparisons, logic, `if`/`else`, `while`, and basic type checking. The Zig compiler (`zig/`) remains as a stable v0.1.0 implementation.

---

## Table of Contents

- [Quick Start](#quick-start)
- [Installation](#installation)
- [Language Overview](#language-overview)
- [Repository Layout](#repository-layout)
- [Building the Compiler](#building-the-compiler)
- [Usage](#usage)
- [Example](#example)
- [Roadmap](#roadmap)
- [Contributing](#contributing)
- [License](#license)

---

## Quick Start

### Ruby compiler (v0.2.0)

1. Install [Ruby 3.0+](https://www.ruby-lang.org/en/downloads/).
2. Install a C++17 compiler (`g++` or `clang++`).
3. Clone the repository:

       git clone https://github.com/Strengthnaxy/zephyr-lang.git
       cd zephyr-lang

4. Compile and run:

       ruby ruby/main.rb hello.zph -o hello
       ./hello

### Zig compiler (v0.1.0, stable)

1. Install [Zig 0.17.0](https://ziglang.org/download/).
2. Build:

       cd zig
       zig build -Doptimize=ReleaseFast

3. Compile:

       cd ..
       ./zig/zig-out/bin/zephyr hello.zph -o hello
       ./hello

---

## Installation

### Requirements

- **Ruby 3.0+** (for the v0.2.0 compiler)
- **Zig 0.17.0+** (for the v0.1.0 compiler)
- C++17 compiler: [`g++`](https://gcc.gnu.org/) or [`clang++`](https://clang.llvm.org/)
- Linux, macOS, or Windows (WSL recommended)

### Arch Linux

    sudo pacman -S ruby gcc zig

### Debian / Ubuntu

    sudo apt install ruby gcc zig

### From source

    git clone https://github.com/Strengthnaxy/zephyr-lang.git
    cd zephyr-lang

The Ruby compiler is at `ruby/main.rb`. The Zig compiler is at `zig/zig-out/bin/zephyr` after building.

---

## Language Overview

### Types

- `i32` — 32-bit signed integer
- `i64` — 64-bit signed integer
- `f64` — 64-bit floating point
- `bool` — boolean
- `string` — UTF-8 string
- `void` — no value

### Statements

- `let` — immutable binding
- `var` — mutable binding
- `return` — return from function
- `print` — print to stdout
- `if` / `else` — conditional
- `while` — loop
- expression statement

### Functions

    fn name(param: Type, ...) -> Type {
        // body
    }

### Example

    fn add(a: i32, b: i32) -> i32 {
        return a + b;
    }

    fn main() -> i32 {
        let x: i32 = 5;
        if x > 0 {
            print(add(x, 10));
        }
        return 0;
    }

### Operators

- Arithmetic: `+`, `-`, `*`, `/`
- Comparison: `==`, `!=`, `<`, `>`, `<=`, `>=`
- Logic: `&&`, `||`

### Design rules

- No exceptions
- No operator overloading
- No hidden control flow
- Explicit types
- Transpiles to readable C++17

---

## Repository Layout

    zephyr-lang/
    ├── .github/        CI, issue and PR templates
    ├── ruby/           v0.2.0 compiler (lexer, parser, checker, codegen)
    ├── zig/            v0.1.0 compiler (lexer, parser, codegen)
    ├── rust/           expression parser skeleton
    ├── ocaml/          expression parser skeleton
    ├── cpp/            runtime for generated C++
    ├── php/            landing page
    ├── CHANGELOG.md
    ├── LICENSE
    ├── README.md
    ├── SYNTAX.md
    └── VERSION

### Ruby compiler files

- `ruby/main.rb` — entry point, reads `.zph`, writes `.cpp`, invokes `g++`
- `ruby/lexer.rb` — tokenizer
- `ruby/parser.rb` — recursive descent parser producing AST
- `ruby/expr_parser.rb` — expression parser with precedence
- `ruby/checker.rb` — type checker
- `ruby/codegen.rb` — C++17 code generator
- `ruby/ast.rb` — AST definitions
- `ruby/error.rb` — error types

### Zig compiler files

- `zig/main.zig` — entry point
- `zig/lexer.zig` — tokenizer
- `zig/parser.zig` — parser
- `zig/codegen.zig` — C++17 code generator
- `zig/build.zig` — Zig build script

---

## Building the Compiler

### Ruby (v0.2.0)

No build step. Run directly:

    ruby ruby/main.rb hello.zph -o hello

### Zig (v0.1.0)

Requirements:

- Zig 0.17.0+
- A C++17 compiler (`g++` or `clang++`) in `PATH`

Build:

    cd zig
    zig build -Doptimize=ReleaseFast

The binary is placed at `zig/zig-out/bin/zephyr`.

---

## Usage

### Ruby compiler

    ruby ruby/main.rb <input.zph> -o <output>

### Zig compiler

    ./zig/zig-out/bin/zephyr <input.zph> -o <output>

Example:

    ruby ruby/main.rb hello.zph -o hello
    ./hello

Zephyr writes `<output>.cpp` next to the output binary and invokes `g++` to compile it.

### Pipeline

1. Lexer reads `<input>.zph` and produces tokens.
2. Parser consumes tokens and produces an AST.
3. Type checker validates the AST.
4. Code generator emits `<output>.cpp`.
5. `g++ -std=c++17` compiles `<output>.cpp` into a native binary.

---

## Example

`hello.zph`:

    fn add(a: i32, b: i32) -> i32 {
        return a + b;
    }

    fn main() -> i32 {
        let x: i32 = 5;
        if x > 0 {
            print(add(x, 10));
        }
        return 0;
    }

Compile:

    ruby ruby/main.rb hello.zph -o hello

Run:

    ./hello

Output:

    15

Generated `hello.cpp`:

    #include <iostream>
    #include <string>
    #include <cstdint>

    int32_t add(int32_t a, int32_t b) {
        return (a + b);
    }

    int32_t main() {
        int32_t x = 5;
        if ((x > 0)) {
            std::cout << add(x, 10) << std::endl;
        }
        return 0;
    }

---

## Roadmap

- [x] Lexer with keywords, identifiers, numbers, strings, operators
- [x] Parser for functions, `let`/`var`, `return`, `print`
- [x] C++17 code generation
- [x] Zig 0.17 build system
- [x] Function parameters
- [x] Arithmetic operators (`-`, `*`, `/`)
- [x] Comparison operators (`==`, `!=`, `<`, `>`, `<=`, `>=`)
- [x] Logic operators (`&&`, `||`)
- [x] Control flow (`if`/`else`, `while`)
- [x] Basic type checking
- [x] Ruby compiler (v0.2.0)
- [ ] `for` loops
- [ ] Structs and arrays
- [ ] Pointers
- [ ] Modules and imports
- [ ] Standard library
- [ ] Package manager

---

## Contributing

See [`.github/PULL_REQUEST_TEMPLATE.md`](.github/PULL_REQUEST_TEMPLATE.md). Update `CHANGELOG.md` under `[Unreleased]` for any user-facing change.

### Development

    # Ruby
    for f in ruby/*.rb; do ruby -c "$f"; done

    # Zig
    cd zig
    zig build -Doptimize=ReleaseSafe

CI runs on every push and pull request via GitHub Actions.

---

## License

MIT. See [LICENSE](LICENSE).

---

## Links

- [Ruby](https://www.ruby-lang.org/)
- [Zig](https://ziglang.org/)
- [GCC](https://gcc.gnu.org/)
- [Clang](https://clang.llvm.org/)
- [GitHub repository](https://github.com/Strengthnaxy/zephyr-lang)
- [Issue tracker](https://github.com/Strengthnaxy/zephyr-lang/issues)
- [Releases](https://github.com/Strengthnaxy/zephyr-lang/releases)
