# frozen_string_literal: true

require_relative 'ast'
require_relative 'expr_parser'
require_relative 'error'

module Zephyr
  module Codegen
    TYPE_TO_CPP = {
      i32: 'int32_t', i64: 'int64_t', f64: 'double',
      bool: 'bool', str: 'std::string', void: 'void'
    }.freeze

    def self.generate(program)
      out = +"#include <iostream>\n#include <string>\n#include <cstdint>\n\n"
      program.functions.each do |fn|
        out << "#{TYPE_TO_CPP[fn.ret]} #{fn.name}() {\n"
        fn.body.each { |s| out << emit_stmt(s) }
        out << "}\n\n"
      end
      out
    end

    def self.emit_stmt(stmt)
      case stmt.kind
      when :let, :var
        "  #{TYPE_TO_CPP[stmt.ty]} #{stmt.name} = #{ExprParser.emit_cpp(stmt.value)};\n"
      when :return
        stmt.value ? "  return #{ExprParser.emit_cpp(stmt.value)};\n" : "  return;\n"
      when :print
        "  std::cout << #{ExprParser.emit_cpp(stmt.value)} << std::endl;\n"
      else
        raise CodegenError, "Unknown stmt: #{stmt.inspect}"
      end
    end
  end
end
