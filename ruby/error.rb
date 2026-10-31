# frozen_string_literal: true

module Zephyr
  class LexError < StandardError; end
  class ParseError < StandardError; end
  class CheckError < StandardError; end
  class CodegenError < StandardError; end
end
