type token_type =
  | TNumber | TIdent | TString
  | TFn | TLet | TVar | TReturn
  | TLParen | TRParen | TLBrace | TRBrace
  | TColon | TSemicolon | TArrow
  | TPlus | TMinus | TStar | TSlash
  | TAssign
  | TEof

type token = { kind : token_type; value : string }

let tokenize (src : string) : token list =
  let len = String.length src in
  let pos = ref 0 in
  let tokens = ref [] in

  let peek () = if !pos < len then Some src.[!pos] else None in
  let advance () =
    if !pos < len then (let c = src.[!pos] in incr pos; Some c) else None
  in

  let add kind value = tokens := { kind; value } :: !tokens in

  let rec loop () =
    match peek () with
    | None -> ()
    | Some c when c = ' ' || c = '\t' || c = '\n' || c = '\r' ->
      ignore (advance ()); loop ()
    | Some '/' when !pos + 1 < len && src.[!pos + 1] = '/' ->
      while peek () <> None && peek () <> Some '\n' do ignore (advance ()) done;
      loop ()
    | Some c when (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || c = '_' ->
      let start = !pos in
      while (match peek () with
             | Some ch -> (ch >= 'a' && ch <= 'z') || (ch >= 'A' && ch <= 'Z')
                          || (ch >= '0' && ch <= '9') || ch = '_'
             | None -> false) do
        ignore (advance ())
      done;
      let word = String.sub src start (!pos - start) in
      let kind = match word with
        | "fn" -> TFn | "let" -> TLet | "var" -> TVar | "return" -> TReturn
        | _ -> TIdent
      in
      add kind word; loop ()
    | Some c when c >= '0' && c <= '9' ->
      let start = !pos in
      while (match peek () with
             | Some ch -> ch >= '0' && ch <= '9'
             | None -> false) do
        ignore (advance ())
      done;
      add TNumber (String.sub src start (!pos - start)); loop ()
    | Some '"' ->
      ignore (advance ());
      let start = !pos in
      while peek () <> None && peek () <> Some '"' do ignore (advance ()) done;
      let s = String.sub src start (!pos - start) in
      ignore (advance ());
      add TString s; loop ()
    | Some c ->
      ignore (advance ());
      let kind = match c with
        | '(' -> TLParen | ')' -> TRParen
        | '{' -> TLBrace | '}' -> TRBrace
        | ':' -> TColon | ';' -> TSemicolon
        | '+' -> TPlus | '-' -> TMinus
        | '*' -> TStar | '/' -> TSlash
        | '=' -> TAssign
        | _ -> failwith (Printf.sprintf "Unknown char: %c" c)
      in
      add kind (String.make 1 c); loop ()
  in

  loop ();
  List.rev ({ kind = TEof; value = "" } :: !tokens)
