# frozen_string_literal: true

module Zephyr
  Type = Struct.new(:kind, :inner, :name)
  Expr = Struct.new(:kind, :value, :op, :lhs, :rhs, :args, :callee)
  Stmt = Struct.new(:kind, :name, :ty, :value, :body, :cond, :els)
  Param = Struct.new(:name, :ty)
  Function = Struct.new(:name, :params, :ret, :body)
  Program = Struct.new(:functions)
end
