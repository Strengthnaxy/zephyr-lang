open Ast

exception Parse_error of string

type state = { tokens : Lexer.token array; mutable pos : int }

let peek st = st.tokens.(st.pos)

let next st =
  let t = st.tokens.(st.pos) in
  if st.pos < Array.length st.tokens - 1 then st.pos <- st.pos + 1;
  t

let rec parse_expr tokens =
  let st = { tokens = Array.of_list tokens; pos = 0 } in
  parse_add st

and parse_add st =
  let lhs = parse_mul st in
  let rec loop lhs =
    match (peek st).kind with
    | Lexer.TPlus | Lexer.TMinus ->
      let op = if (next st).kind = Lexer.TPlus then '+' else '-' in
      let rhs = parse_mul st in
      loop (Bin (op, lhs, rhs))
    | _ -> lhs
  in
  loop lhs

and parse_mul st =
  let lhs = parse_prim st in
  let rec loop lhs =
    match (peek st).kind with
    | Lexer.TStar | Lexer.TSlash ->
      let op = if (next st).kind = Lexer.TStar then '*' else '/' in
      let rhs = parse_prim st in
      loop (Bin (op, lhs, rhs))
    | _ -> lhs
  in
  loop lhs

and parse_prim st =
  let t = next st in
  match t.kind with
  | Lexer.TNumber -> Number (int_of_string t.value)
  | Lexer.TIdent -> VarRef t.value
  | Lexer.TLParen ->
    let e = parse_add st in
    ignore (next st);
    e
  | _ -> raise (Parse_error (Printf.sprintf "Unexpected token: %s" t.value))
