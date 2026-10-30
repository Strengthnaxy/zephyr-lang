(* Reference AST for the Zephyr language.
   Kept in sync with parser.zig for cross-checking. *)

type typ =
  | TI32
  | TI64
  | TF64
  | TBool
  | TStr
  | TVoid

type op = Add | Sub | Mul | Div

type expr =
  | Number of int
  | StringLit of string
  | VarRef of string
  | BinOp of op * expr * expr
  | Call of string * expr list

type stmt =
  | Let of string * typ * expr * bool
  | Return of expr option
  | Print of expr
  | ExprStmt of expr

type fn = {
  name : string;
  params : (string * typ) list;
  ret : typ;
  body : stmt list;
}

type program = fn list

let rec validate_expr (_e : expr) : (unit, string) result = Ok ()

let validate_fn (f : fn) : (unit, string) result =
  List.fold_left
    (fun acc s ->
      match acc with
      | Error _ as e -> e
      | Ok () ->
        match s with
        | ExprStmt e -> validate_expr e
        | Print e -> validate_expr e
        | Return (Some e) -> validate_expr e
        | Return None -> Ok ()
        | Let (_, _, e, _) -> validate_expr e)
    (Ok ()) f.body

let validate (p : program) : (unit, string) result =
  List.fold_left
    (fun acc f ->
      match acc with
      | Error _ as e -> e
      | Ok () -> validate_fn f)
    (Ok ()) p
