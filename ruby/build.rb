#!/usr/bin/env ruby
# frozen_string_literal: true

# Helper that builds the Zig compiler and compiles every .zph file
# in the examples directory. Intended for local development only.

require 'fileutils'

ROOT = File.expand_path(__dir__ + '/..')
ZIG_DIR = File.join(ROOT, 'zig')
EXAMPLES = File.join(ROOT, 'examples')

def run(cmd, dir: ROOT)
  puts "> #{cmd}"
  success = system(cmd, chdir: dir)
  raise "Command failed: #{cmd}" unless success
end

def build_compiler
  run('zig build -Doptimize=ReleaseFast', dir: ZIG_DIR)
end

def compile_examples
  return unless Dir.exist?(EXAMPLES)

  Dir.glob(File.join(EXAMPLES, '*.zph')).each do |src|
    out = src.sub(/\.zph\z/, '')
    bin = File.join(ZIG_DIR, 'zig-out', 'bin', 'zephyr')
    run("#{bin} #{src} -o #{out}")
  end
end

build_compiler
compile_examples
puts 'Done.'
