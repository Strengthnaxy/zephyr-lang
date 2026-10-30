mod ast;
mod lexer;
mod expr_parser;

use lexer::Lexer;
use expr_parser::ExprParser;

fn main() {
    let src = "1 + 2 * 3";
    println!("Source: {src}");

    let tokens = Lexer::new(src).tokenize().expect("lex error");
    let mut parser = ExprParser::new(tokens);
    let expr = parser.parse().expect("parse error");
    let cpp = expr_parser::emit_cpp(&expr);
    println!("C++: {cpp}");
}
