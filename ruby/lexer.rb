# frozen_string_literal: true

require_relative 'error'

module Zephyr
  Token = Struct.new(:type, :value)

  class Lexer
    KEYWORDS = {
      'fn' => :fn, 'let' => :let, 'var' => :var, 'return' => :return,
      'if' => :if, 'else' => :else, 'while' => :while
    }.freeze

    def initialize(source)
      @src = source
      @pos = 0
    end

    def tokenize
      tokens = []
      loop do
        skip_whitespace
        break if @pos >= @src.length
        c = @src[@pos]

        if c == '/' && @src[@pos + 1] == '/'
          skip_comment
          next
        end

        if c =~ /[A-Za-z_]/
          tokens << read_ident
        elsif c =~ /[0-9]/
          tokens << read_number
        elsif c == '"'
          tokens << read_string
        else
          tokens << read_symbol
        end
      end
      tokens << Token.new(:eof, '')
      tokens
    end

    private

    def skip_whitespace
      @pos += 1 while @pos < @src.length && @src[@pos] =~ /\s/
    end

    def skip_comment
      @pos += 1 while @pos < @src.length && @src[@pos] != "\n"
    end

    def read_ident
      start = @pos
      @pos += 1 while @pos < @src.length && @src[@pos] =~ /[A-Za-z0-9_]/
      word = @src[start...@pos]
      Token.new(KEYWORDS.fetch(word, :ident), word)
    end

    def read_number
      start = @pos
      @pos += 1 while @pos < @src.length && @src[@pos] =~ /[0-9]/
      Token.new(:number, @src[start...@pos])
    end

    def read_string
      @pos += 1
      start = @pos
      @pos += 1 while @pos < @src.length && @src[@pos] != '"'
      s = @src[start...@pos]
      @pos += 1
      Token.new(:string, s)
    end

    def read_symbol
      c = @src[@pos]
      @pos += 1
      case c
      when '(' then Token.new(:lparen, c)
      when ')' then Token.new(:rparen, c)
      when '{' then Token.new(:lbrace, c)
      when '}' then Token.new(:rbrace, c)
      when ':' then Token.new(:colon, c)
      when ';' then Token.new(:semicolon, c)
      when '+' then Token.new(:plus, c)
      when '-' then Token.new(:minus, c)
      when '*' then Token.new(:star, c)
      when '/' then Token.new(:slash, c)
      when '=' then Token.new(:assign, c)
      else raise LexError, "Unknown char: #{c}"
      end
    end
  end
end
