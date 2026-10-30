#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'cli'

exit Zephyr::CLI.run(ARGV)
