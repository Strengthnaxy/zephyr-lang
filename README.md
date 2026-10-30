# Zephyr

[![CI](https://github.com/yourname/zephyr-lang/actions/workflows/ci.yml/badge.svg)](https://github.com/yourname/zephyr-lang/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-0.1.0-informational.svg)](VERSION)

Zephyr is a statically typed, non-mainstream systems language. It is designed as a simpler and safer alternative to C++ while keeping native performance.

Zephyr does not have its own machine-code backend. It transpiles to C++17 and relies on a mature compiler (GCC or Clang) to produce native binaries. This gives a reliable guarantee: if the generated C++ compiles, Zephyr works.

## Repository Layout

    zephyr-lang/
    ├── .github/        CI, issue and PR templates
    ├── zig/            Compiler (lexer, parser, C++ codegen)
    ├── cpp/            Runtime headers for generated code
    ├── rust/           Windows installer
    ├── elixir/         Language server prototype
    ├── haskell/        AST specification (reference)
    └── examples/       Sample Zephyr programs

## Quick Start

1. Install Zig 0.13.0 or newer.
2. Build the compiler:

       cd zig
       zig build -Doptimize=ReleaseFast

3. Compile a sample:

       ./zig-out/bin/zephyr ../examples/hello.zph -o hello

4. Run:

       ./hello

## Installation

### Windows

    cd rust
    cargo build --release
    ./target/release/zephyr-installer.exe

The installer copies the compiler and runtime headers to `%LOCALAPPDATA%\Zephyr` and prints instructions to add that directory to `PATH`.

### Linux (portable tarball)

    tar -xzf zephyr-lang-0.1.0-linux-x86_64.tar.gz
    cd zephyr-lang-0.1.0
    ./install.sh

`install.sh` copies `bin/zephyr` to `~/.local/bin` and `lib/runtime.hpp` to `~/.local/share/zephyr`, then prints a `PATH` reminder.

### AUR (Arch Linux)

Create a separate repository `zephyr-bin`. `PKGBUILD`:

    pkgname=zephyr-bin
    pkgver=0.1.0
    pkgrel=1
    pkgdesc="Zephyr language compiler (transpiles to C++)"
    arch=('x86_64')
    url="https://github.com/yourname/zephyr-lang"
    license=('MIT')
    depends=('gcc' 'zig')
    source=("$pkgname-$pkgver.tar.gz::https://github.com/yourname/zephyr-lang/archive/v$pkgver.tar.gz")
    sha256sums=('SKIP')

    package() {
      install -Dm755 zig/zig-out/bin/zephyr "$pkgdir/usr/bin/zephyr"
      install -Dm644 cpp/runtime.hpp "$pkgdir/usr/include/zephyr/runtime.hpp"
    }

Publish:

    git clone ssh://aur@aur.archlinux.org/zephyr-bin.git
    cd zephyr-bin
    makepkg --printsrcinfo > .SRCINFO
    git add PKGBUILD .SRCINFO
    git commit -m "initial"
    git push

## Language Overview

Types: `i32`, `i64`, `f64`, `bool`, `string`, `void`.

Statements: `let` (immutable), `var` (mutable), `return`, `print`, expression statement.

Functions: `fn name() -> Type { ... }`.

No exceptions, no operator overloading, no hidden control flow.

## Example

    fn main() -> i32 {
        let msg: string = "Hello from Zephyr";
        print(msg);
        return 0;
    }

## Building the Compiler

Requirements:

- Zig 0.13.0+
- A C++17 compiler (`g++` or `clang++`) in `PATH`

Build:

    cd zig
    zig build -Doptimize=ReleaseFast

## Development

Run tests locally:

    cd zig && zig build test
    cd ../rust && cargo test
    cd ../elixir && mix test
    cd ../haskell && ghc -fno-code ZephyrAst.hs

CI runs all of the above on every push and pull request.

## Contributing

See `.github/PULL_REQUEST_TEMPLATE.md`. Update `CHANGELOG.md` under `[Unreleased]` for any user-facing change.

## License

MIT. See [LICENSE](LICENSE).
