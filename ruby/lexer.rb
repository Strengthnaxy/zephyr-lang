# frozen_string_literal: true

require_relative 'error'
require_relative 'ast'

module Zephyr
  Token = Struct.new(:type, :value)

  KEYWORDS = {
    'fn' => :fn, 'let' => :let, 'var' => :var, 'return' => :return,
    'if' => :if, 'else' => :else, 'while' => :while,
    'true' => :true, 'false' => :false
  }.freeze

  def self.tokenize(src)
    toks = []
    pos = 0
    while pos < src.length
      c = src[pos]
      if c =~ /\s/ then pos += 1; next end
      if c == '/' && src[pos + 1] == '/' then pos += 1 while pos < src.length && src[pos] != "\n"; next end
      if c =~ /[A-Za-z_]/ then
        start = pos
        pos += 1 while pos < src.length && src[pos] =~ /[A-Za-z0-9_]/
        w = src[start...pos]
        toks << Token.new(KEYWORDS.fetch(w, :ident), w)
      elsif c =~ /[0-9]/ then
        start = pos
        pos += 1 while pos < src.length && src[pos] =~ /[0-9]/
        toks << Token.new(:number, src[start...pos])
      elsif c == '"' then
        pos += 1
        start = pos
        pos += 1 while pos < src.length && src[pos] != '"'
        toks << Token.new(:string, src[start...pos])
        pos += 1
      else
        two = src[pos, 2]
        tt = { '==' => :eq_eq, '!=' => :bang_eq, '<=' => :le, '>=' => :ge, '&&' => :and_and, '||' => :or_or, '->' => :arrow }[two]
        if tt then pos += 2; toks << Token.new(tt, two); next end
        tt = { '(' => :lparen, ')' => :rparen, '{' => :lbrace, '}' => :rbrace,
               ':' => :colon, ';' => :semicolon, ',' => :comma,
               '+' => :plus, '-' => :minus, '*' => :star, '/' => :slash, '=' => :assign,
               '<' => :lt, '>' => :gt }[c]
        raise LexError, "Unknown char: #{c}" unless tt
        pos += 1
        toks << Token.new(tt, c)
      end
    end
    toks << Token.new(:eof, '')
  end
end
