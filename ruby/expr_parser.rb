# frozen_string_literal: true

require_relative 'ast'
require_relative 'error'

module Zephyr
  class ExprParser
    def initialize(tokens)
      @tokens = tokens
      @pos = 0
    end

    def parse_expr
      parse_add
    end

    def self.emit_cpp(expr)
      case expr.kind
      when :number then expr.value.to_s
      when :var_ref then expr.value.to_s
      when :bin
        "(#{emit_cpp(expr.lhs)} #{expr.op} #{emit_cpp(expr.rhs)})"
      else
        raise CodegenError, "Unknown expression: #{expr.inspect}"
      end
    end

    private

    def peek = @tokens[@pos]

    def next_token
      t = @tokens[@pos]
      @pos += 1 if @pos < @tokens.length - 1
      t
    end

    def parse_add
      lhs = parse_mul
      while %i[plus minus].include?(peek.type)
        op = next_token.type == :plus ? '+' : '-'
        rhs = parse_mul
        lhs = Expr.new(:bin, nil, op, lhs, rhs)
      end
      lhs
    end

    def parse_mul
      lhs = parse_prim
      while %i[star slash].include?(peek.type)
        op = next_token.type == :star ? '*' : '/'
        rhs = parse_prim
        lhs = Expr.new(:bin, nil, op, lhs, rhs)
      end
      lhs
    end

    def parse_prim
      t = next_token
      case t.type
      when :number then Expr.new(:number, Integer(t.value), nil, nil, nil)
      when :ident  then Expr.new(:var_ref, t.value, nil, nil, nil)
      when :lparen
        e = parse_expr
        next_token
        e
      else
        raise ParseError, "Parse error at #{t.inspect}"
      end
    end
  end
end
