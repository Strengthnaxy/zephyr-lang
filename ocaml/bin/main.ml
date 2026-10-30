let () =
  let src = "1 + 2 * 3" in
  Printf.printf "Source: %s\n" src;
  let tokens = Zephyr_ocaml.Lexer.tokenize src in
  let expr = Zephyr_ocaml.Expr_parser.parse_expr tokens in
  let cpp = Zephyr_ocaml.Codegen.emit_cpp expr in
  Printf.printf "C++: %s\n" cpp
