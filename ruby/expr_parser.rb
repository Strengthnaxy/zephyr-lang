# frozen_string_literal: true

require_relative 'ast'
require_relative 'error'

module Zephyr
  class ExprParser
    attr_reader :pos

    def initialize(toks, pos = 0)
      @toks = toks
      @pos = pos
    end

    def parse = parse_or

    def self.emit_cpp(e)
      case e.kind
      when :number then e.value.to_s
      when :string then "\"#{e.value}\""
      when :bool then e.value.to_s
      when :var_ref then e.value
      when :bin then "(#{emit_cpp(e.lhs)} #{e.op} #{emit_cpp(e.rhs)})"
      when :call then "#{e.callee}(#{e.args.map { |a| emit_cpp(a) }.join(', ')})"
      else raise CodegenError, "Unknown expr: #{e.inspect}"
      end
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
      raise ParseError, "Expected #{tt}, got #{t.type}" unless t.type == tt
      t
    end

    def parse_or
      l = parse_and
      while peek.type == :or_or
        next_token
        l = Expr.new(:bin, nil, '||', l, parse_and)
      end
      l
    end

    def parse_and
      l = parse_cmp
      while peek.type == :and_and
        next_token
        l = Expr.new(:bin, nil, '&&', l, parse_cmp)
      end
      l
    end

    def parse_cmp
      l = parse_add
      while %i[eq_eq bang_eq lt gt le ge].include?(peek.type)
        op = { eq_eq: '==', bang_eq: '!=', lt: '<', gt: '>', le: '<=', ge: '>=' }[next_token.type]
        l = Expr.new(:bin, nil, op, l, parse_add)
      end
      l
    end

    def parse_add
      l = parse_mul
      while %i[plus minus].include?(peek.type)
        op = next_token.type == :plus ? '+' : '-'
        l = Expr.new(:bin, nil, op, l, parse_mul)
      end
      l
    end

    def parse_mul
      l = parse_prim
      while %i[star slash].include?(peek.type)
        op = next_token.type == :star ? '*' : '/'
        l = Expr.new(:bin, nil, op, l, parse_prim)
      end
      l
    end

    def parse_prim
      t = next_token
      case t.type
      when :number then Expr.new(:number, t.value.to_i)
      when :string then Expr.new(:string, t.value)
      when :true then Expr.new(:bool, true)
      when :false then Expr.new(:bool, false)
      when :ident
        if peek.type == :lparen
          next_token
          args = []
          unless peek.type == :rparen
            loop do
              args << parse
              break unless peek.type == :comma
              next_token
            end
          end
          expect(:rparen)
          Expr.new(:call, nil, nil, nil, nil, args, t.value)
        else
          Expr.new(:var_ref, t.value)
        end
      when :lparen
        e = parse
        expect(:rparen)
        e
      else
        raise ParseError, "Unexpected prim: #{t.type}"
      end
    end
  end
end
