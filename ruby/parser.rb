# frozen_string_literal: true

require_relative 'ast'
require_relative 'lexer'
require_relative 'expr_parser'
require_relative 'error'

module Zephyr
  TYPE_MAP = {
    'i32' => :i32, 'i64' => :i64, 'f64' => :f64,
    'bool' => :bool, 'string' => :str, 'void' => :void
  }.freeze

  class Parser
    def initialize(toks)
      @toks = toks
      @pos = 0
    end

    def program
      fns = []
      fns << fn_decl until peek.type == :eof
      Program.new(fns)
    end

    private

    def peek = @toks[@pos]

    def next_token
      t = @toks[@pos]
      @pos += 1 if @pos < @toks.length - 1
      t
    end

    def expect(tt)
      t = next_token
      raise ParseError, "Expected #{tt}, got #{t.type} (#{t.value.inspect})" unless t.type == tt
      t
    end

    def parse_expr
      # Разбираем выражение на тех же токенах и с той же позицией
      ep = ExprParser.new(@toks, @pos)
      e = ep.parse
      @pos = ep.pos
      e
    end

    def parse_type
      t = expect(:ident)
      base = TYPE_MAP[t.value]
      base ? Type.new(base) : Type.new(:struct_, nil, t.value)
    end

    def fn_decl
      expect(:fn)
      name = expect(:ident).value
      expect(:lparen)
      params = []
      unless peek.type == :rparen
        loop do
          pn = expect(:ident).value
          expect(:colon)
          params << Param.new(pn, parse_type)
          break unless peek.type == :comma
          next_token
        end
      end
      expect(:rparen)
      expect(:arrow)
      ret = parse_type
      body = block
      Function.new(name, params, ret, body)
    end

    def block
      expect(:lbrace)
      out = []
      out << stmt until peek.type == :rbrace
      expect(:rbrace)
      out
    end

    def stmt
      case peek.type
      when :let, :var
        kw = next_token
        name = expect(:ident).value
        expect(:colon)
        ty = parse_type
        expect(:assign)
        v = parse_expr
        expect(:semicolon)
        Stmt.new(kw.type == :var ? :var : :let, name, ty, v)
      when :return
        next_token
        v = peek.type == :semicolon ? nil : parse_expr
        expect(:semicolon)
        Stmt.new(:return, nil, nil, v)
      when :if
        next_token
        expect(:lparen)
        c = parse_expr
        expect(:rparen)
        then_body = block
        els = peek.type == :else ? (next_token; block) : nil
        Stmt.new(:if, nil, nil, nil, then_body, c, els)
      when :while
        next_token
        expect(:lparen)
        c = parse_expr
        expect(:rparen)
        Stmt.new(:while, nil, nil, nil, block, c)
      when :ident
        if peek.value == 'print'
          next_token
          expect(:lparen)
          v = parse_expr
          expect(:rparen)
          expect(:semicolon)
          return Stmt.new(:print, nil, nil, v)
        end
        e = parse_expr
        expect(:semicolon)
        Stmt.new(:expr, nil, nil, e)
      else
        raise ParseError, "Unexpected stmt: #{peek.type}"
      end
    end
  end
end
