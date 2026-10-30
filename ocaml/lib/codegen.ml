open Ast

let rec emit_cpp = function
  | Number n -> string_of_int n
  | VarRef v -> v
  | Bin (op, l, r) ->
    Printf.sprintf "(%s %c %s)" (emit_cpp l) op (emit_cpp r)
