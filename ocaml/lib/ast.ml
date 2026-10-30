type expr =
  | Number of int
  | VarRef of string
  | Bin of char * expr * expr

type typ =
  | TI32 | TI64 | TF64 | TBool | TStr | TVoid

type stmt =
  | Let of string * typ * expr * bool
  | Return of expr option
  | Print of expr

type fn = {
  name : string;
  params : (string * typ) list;
  ret : typ;
  body : stmt list;
}

type program = fn list
