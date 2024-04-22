#! /usr/bin/env ruby
require 'ripper'
require 'json'

if ARGV[0]
 path = ARGV[0]
else
 puts "No file path was provided, assuming './Puppetfile'."
 puts "If you'd like to run this on a different file path, provide it as an argument like '#{$PROGRAM_NAME} /path/to/Puppetfile'."
 puts "If the file contains any Ruby methods, this will print them and then exit with an error code."
 path = 'Puppetfile'
end

tokens = Ripper.sexp(File.read(path))

if tokens.nil?
  # no Ruby code
  exit 0
end

tokens.flatten!
indices = tokens.map.with_index { |a, i| ([:command, :xstring_literal].include? a) ? i : nil }.compact
methods = indices.map { |i| tokens[i + 2] }.flatten.compact
methods.reject! { |name| %w[mod forge moduledir].include? name }

output = methods.uniq.map do |name|
  {
    name: name,
    count: methods.count(name),
  }
end

if output.size > 0
  puts JSON.pretty_generate(output)
  exit 1
else
  # Only expected Puppetfile methods
  exit 0
end
