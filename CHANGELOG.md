# Changelog

All notable changes to this project are documented here.
Format follows Keep a Changelog. Versioning follows Semantic Versioning.

## [Unreleased]

## [0.1.0] - 2026-10-30

### Added
- Zig compiler with lexer, parser and C++17 code generator.
- Support for `fn`, `let`, `var`, `return`, `print`.
- Types: `i32`, `i64`, `f64`, `bool`, `string`, `void`.
- Transpiles to C++17 and compiles with `g++`.
- Example program `hello.zph`.

### Changed
- Migrated compiler to Zig 0.17 API:
  - `std.process.Init` for `main`.
  - `std.Io.Dir` for file access.
  - `std.Io.Writer.Allocating` for code generation.
  - `std.process.spawn` for launching `g++`.
  - `DebugAllocator` instead of `GeneralPurposeAllocator`.
  - `ArrayList.empty` and `append(allocator, ...)`.
