# Zephyr

[![CI](https://github.com/Strengthnaxy/zephyr-lang/actions/workflows/ci.yml/badge.svg)](https://github.com/Strengthnaxy/zephyr-lang/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/badge/version-0.1.0-blue.svg)](https://github.com/Strengthnaxy/zephyr-lang/blob/main/VERSION)
[![Zig](https://img.shields.io/badge/Zig-0.17.0-orange.svg)](https://ziglang.org/)
[![C++](https://img.shields.io/badge/C%2B%2B-17-00599C.svg)](https://isocpp.org/)

**Zephyr** is a statically typed, non-mainstream systems language. It is designed as a simpler and safer alternative to C++ while keeping native performance.

Zephyr does not have its own machine-code backend. It transpiles to C++17 and relies on a mature compiler (GCC or Clang) to produce native binaries. This gives a reliable guarantee: if the generated C++ compiles, Zephyr works.

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

1. Install [Zig 0.17.0](https://ziglang.org/download/) or newer.
2. Install a C++17 compiler (`g++` or `clang++`).
3. Clone the repository:

       git clone https://github.com/Strengthnaxy/zephyr-lang.git
       cd zephyr-lang

4. Build the compiler:

       cd zig
       zig build -Doptimize=ReleaseFast

5. Create `hello.zph`:

       fn main() -> i32 {
           let msg: string = "Hello world";
           print(msg);
           return 0;
       }

6. Compile and run:

       cd ..
       ./zig/zig-out/bin/zephyr hello.zph -o hello
       ./hello

Expected output:

    Hello world

---

## Installation

### Requirements

- [Zig 0.17.0+](https://ziglang.org/download/)
- C++17 compiler: [`g++`](https://gcc.gnu.org/) or [`clang++`](https://clang.llvm.org/)
- Linux, macOS, or Windows (WSL recommended)

### Arch Linux

    sudo pacman -S zig gcc

### Debian / Ubuntu

    sudo apt install zig gcc

### From source

    git clone https://github.com/Strengthnaxy/zephyr-lang.git
    cd zephyr-lang/zig
    zig build -Doptimize=ReleaseFast

The compiler binary is placed at `zig/zig-out/bin/zephyr`.

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
- expression statement

### Functions

    fn name() -> Type {
        // body
    }

### Example

    fn main() -> i32 {
        let msg: string = "Hello world";
        print(msg);
        return 0;
    }

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
    ├── zig/            Compiler (lexer, parser, C++ codegen)
    ├── CHANGELOG.md
    ├── LICENSE
    ├── README.md
    └── VERSION

### Compiler files

- `zig/main.zig` — entry point, reads `.zph`, writes `.cpp`, invokes `g++`
- `zig/lexer.zig` — tokenizer
- `zig/parser.zig` — recursive descent parser producing AST
- `zig/codegen.zig` — C++17 code generator
- `zig/build.zig` — Zig build script

---

## Building the Compiler

Requirements:

- Zig 0.17.0+
- A C++17 compiler (`g++` or `clang++`) in `PATH`

Build:

    cd zig
    zig build -Doptimize=ReleaseFast

For a debug build:

    cd zig
    zig build

The binary is placed at `zig/zig-out/bin/zephyr`.

---

## Usage

    zephyr <input.zph> -o <output>

Example:

    zephyr hello.zph -o hello

Zephyr writes `<output>.cpp` next to the output binary and invokes `g++` to compile it.

### Pipeline

1. Lexer reads `<input>.zph` and produces tokens.
2. Parser consumes tokens and produces an AST.
3. Code generator emits `<output>.cpp`.
4. `g++ -std=c++17` compiles `<output>.cpp` into a native binary.

---

## Example

`hello.zph`:

    fn main() -> i32 {
        let msg: string = "Hello world";
        print(msg);
        return 0;
    }

Compile:

    ./zig/zig-out/bin/zephyr hello.zph -o hello

Run:

    ./hello

Output:

    Hello world

Generated `hello.cpp`:

    #include <iostream>
    #include <string>
    #include <cstdint>

    int32_t main() {
        std::string msg = "Hello world";
        std::cout << msg << std::endl;
        return 0;
    }

---

## Roadmap

- [x] Lexer with keywords, identifiers, numbers, strings, operators
- [x] Parser for functions, `let`/`var`, `return`, `print`
- [x] C++17 code generation
- [x] Zig 0.17 build system
- [ ] Arithmetic operators (`-`, `*`, `/`)
- [ ] Function parameters
- [ ] Type checking
- [ ] Structs and arrays
- [ ] Control flow (`if`, `while`)
- [ ] Standard library
- [ ] Package manager

---

## Contributing

See [`.github/PULL_REQUEST_TEMPLATE.md`](.github/PULL_REQUEST_TEMPLATE.md). Update `CHANGELOG.md` under `[Unreleased]` for any user-facing change.

### Development

    cd zig
    zig build -Doptimize=ReleaseSafe

CI runs on every push and pull request via GitHub Actions.

---

## License

MIT. See [LICENSE](LICENSE).

---

## Links

- [Zig](https://ziglang.org/)
- [GCC](https://gcc.gnu.org/)
- [Clang](https://clang.llvm.org/)
- [GitHub repository](https://github.com/Strengthnaxy/zephyr-lang)
- [Issue tracker](https://github.com/Strengthnaxy/zephyr-lang/issues)
- [Releases](https://github.com/Strengthnaxy/zephyr-lang/releases)
