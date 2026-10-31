# frozen_string_literal: true

require_relative 'ast'
require_relative 'expr_parser'

module Zephyr
  CPP_TYPE = { i32: 'int32_t', i64: 'int64_t', f64: 'double', bool: 'bool', str: 'std::string', void: 'void' }.freeze

  def self.emit(prog)
    out = +"#include <iostream>\n#include <string>\n#include <cstdint>\n\n"
    prog.functions.each do |f|
      params = f.params.map { |p| "#{CPP_TYPE[p.ty.kind]} #{p.name}" }.join(', ')
      out << "#{CPP_TYPE[f.ret.kind]} #{f.name}(#{params}) {\n"
      f.body.each { |s| out << emit_stmt(s) }
      out << "}\n\n"
    end
    out
  end

  def self.emit_stmt(s)
    case s.kind
    when :let, :var then "  #{CPP_TYPE[s.ty.kind]} #{s.name} = #{ExprParser.emit_cpp(s.value)};\n"
    when :return then s.value ? "  return #{ExprParser.emit_cpp(s.value)};\n" : "  return;\n"
    when :print then "  std::cout << #{ExprParser.emit_cpp(s.value)} << std::endl;\n"
    when :expr then "  #{ExprParser.emit_cpp(s.value)};\n"
    when :if
      o = +"  if (#{ExprParser.emit_cpp(s.cond)}) {\n"
      s.body.each { |x| o << emit_stmt(x).gsub(/^/, '  ') }
      o << "  }"
      if s.els
        o << " else {\n"
        s.els.each { |x| o << emit_stmt(x).gsub(/^/, '  ') }
        o << "  }"
      end
      o << "\n"
    when :while
      o = +"  while (#{ExprParser.emit_cpp(s.cond)}) {\n"
      s.body.each { |x| o << emit_stmt(x).gsub(/^/, '  ') }
      o << "  }\n"
    end
  end
end
