#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'lexer'
require_relative 'parser'
require_relative 'checker'
require_relative 'codegen'
require_relative 'error'

if ARGV.length < 3
  warn 'Usage: ruby main.rb input.zph -o output'
  exit 1
end

begin
  src = File.read(ARGV[0])
  toks = Zephyr.tokenize(src)
  prog = Zephyr::Parser.new(toks).program
  Zephyr.check(prog)
  cpp = Zephyr.emit(prog)
  File.write("#{ARGV[2]}.cpp", cpp)
  exit(system('g++', '-std=c++17', "#{ARGV[2]}.cpp", '-o', ARGV[2]) ? 0 : 1)
rescue Zephyr::LexError, Zephyr::ParseError, Zephyr::CheckError => e
  warn "Error: #{e.message}"
  exit 1
end
