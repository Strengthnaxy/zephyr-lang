type expr =
  | Number of int
  | VarRef of string
  | Bin of char * expr * expr
