# frozen_string_literal: true

module Zephyr
  Type = Struct.new(:kind, :inner)
  Expr = Struct.new(:kind, :value, :op, :lhs, :rhs)
  Stmt = Struct.new(:kind, :name, :ty, :value, :body, :cond, :els)
  Function = Struct.new(:name, :params, :ret, :body)
  Program = Struct.new(:functions)
end
