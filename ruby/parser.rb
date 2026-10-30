# frozen_string_literal: true

require_relative 'ast'
require_relative 'lexer'
require_relative 'error'

module Zephyr
  class Parser
    TYPE_MAP = {
      'i32' => :i32, 'i64' => :i64, 'f64' => :f64,
      'bool' => :bool, 'string' => :str, 'void' => :void
    }.freeze

    def initialize(tokens)
      @tokens = tokens
      @pos = 0
    end

    def parse_program
      fns = []
      fns << parse_fn until peek.type == :eof
      Program.new(fns)
    end

    private

    def peek = @tokens[@pos]

    def next_token
      t = @tokens[@pos]
      @pos += 1 if @pos < @tokens.length - 1
      t
    end

    def expect(type)
      t = next_token
      raise ParseError, "Expected #{type}, got #{t.type}" unless t.type == type
      t
    end

    def parse_type
      t = expect(:ident)
      TYPE_MAP.fetch(t.value) { raise ParseError, "Unknown type: #{t.value}" }
    end

    def parse_fn
      expect(:fn)
      name = expect(:ident).value
      expect(:lparen)
      expect(:rparen)
      expect(:minus)
      next_token
      ret = parse_type
      expect(:lbrace)
      body = []
      body << parse_stmt until peek.type == :rbrace
      expect(:rbrace)
      Function.new(name, [], ret, body)
    end

    def parse_stmt
      case peek.type
      when :let, :var
        kw = next_token
        name = expect(:ident).value
        expect(:colon)
        ty = parse_type
        expect(:assign)
        value = ExprParser.new(@tokens[@pos..]).parse_expr
        expect(:semicolon)
        Stmt.new(kw.type == :var ? :var : :let, name, ty, value, nil, nil, nil)
      when :return
        next_token
        value = peek.type == :semicolon ? nil : ExprParser.new(@tokens[@pos..]).parse_expr
        expect(:semicolon)
        Stmt.new(:return, nil, nil, value, nil, nil, nil)
      when :ident
        if peek.value == 'print'
          next_token
          expect(:lparen)
          value = ExprParser.new(@tokens[@pos..]).parse_expr
          expect(:rparen)
          expect(:semicolon)
          return Stmt.new(:print, nil, nil, value, nil, nil, nil)
        end
        raise ParseError, "Unexpected ident: #{peek.value}"
      else
        raise ParseError, "Unexpected token: #{peek.type}"
      end
    end
  end
end
