type token_type = TNumber | TIdent | TPlus | TMinus | TStar | TSlash | TLParen | TRParen | TEof
type token = { kind : token_type; value : string }
