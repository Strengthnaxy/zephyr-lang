# frozen_string_literal: true

require_relative 'ast'
require_relative 'error'

module Zephyr
  def self.check(prog)
    fns = prog.functions.to_h { |f| [f.name, f] }
    prog.functions.each do |f|
      env = f.params.to_h { |p| [p.name, p.ty] }
      f.body.each { |s| check_stmt(s, env, f.ret, fns) }
    end
  end

  def self.check_stmt(s, env, ret, fns)
    case s.kind
    when :let, :var
      t = check_expr(s.value, env, fns)
      raise CheckError, "Type mismatch in #{s.name}" if t && t.kind != s.ty.kind
      env[s.name] = s.ty
    when :return
      t = s.value ? check_expr(s.value, env, fns) : Type.new(:void)
      raise CheckError, "Return type mismatch" if t && t.kind != ret.kind
    when :print
      check_expr(s.value, env, fns)
    when :if
      t = check_expr(s.cond, env, fns)
      raise CheckError, "If condition must be bool" unless t && t.kind == :bool
      s.body.each { |x| check_stmt(x, env, ret, fns) }
      s.els&.each { |x| check_stmt(x, env, ret, fns) }
    when :while
      t = check_expr(s.cond, env, fns)
      raise CheckError, "While condition must be bool" unless t && t.kind == :bool
      s.body.each { |x| check_stmt(x, env, ret, fns) }
    end
  end

  def self.check_expr(e, env, fns)
    case e.kind
    when :number then Type.new(:i32)
    when :string then Type.new(:str)
    when :bool then Type.new(:bool)
    when :var_ref
      env[e.value] || (raise CheckError, "Undeclared #{e.value}")
    when :bin
      lt = check_expr(e.lhs, env, fns)
      rt = check_expr(e.rhs, env, fns)
      case e.op
      when '+', '-', '*', '/'
        raise CheckError, "Arithmetic mismatch" unless lt&.kind == rt&.kind && %i[i32 f64].include?(lt.kind)
        lt
      when '==', '!=', '<', '>', '<=', '>='
        raise CheckError, "Comparison mismatch" if lt && rt && lt.kind != rt.kind
        Type.new(:bool)
      when '&&', '||'
        raise CheckError, "Logical requires bool" unless lt&.kind == :bool && rt&.kind == :bool
        Type.new(:bool)
      end
    when :call
      f = fns[e.callee] or raise CheckError, "Unknown function #{e.callee}"
      raise CheckError, "Arg count mismatch" if e.args.length != f.params.length
      e.args.each { |a| check_expr(a, env, fns) }
      f.ret
    end
  end
end
