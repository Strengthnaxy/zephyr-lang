# frozen_string_literal: true

require_relative 'lexer'
require_relative 'parser'
require_relative 'codegen'
require_relative 'error'

module Zephyr
  module CLI
    def self.run(argv)
      if argv.length < 2
        warn 'Usage: ruby main.rb <input.zph> -o <output>'
        return 1
      end

      input = argv[0]
      output = argv[2]

      source = File.read(input)
      tokens = Lexer.new(source).tokenize
      program = Parser.new(tokens).parse_program
      cpp = Codegen.generate(program)

      File.write("#{output}.cpp", cpp)
      ok = system('g++', '-std=c++17', "#{output}.cpp", '-o', output)
      ok ? 0 : 1
    rescue LexError, ParseError, CodegenError => e
      warn "Error: #{e.message}"
      1
    end
  end
end
