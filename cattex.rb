#!/bin/sh
exec ruby -x "$0" "$@"
#!ruby

require 'ltx'

if ARGV.size == 0
  rootfile = "main.tex" # default name
elsif ARGV.size == 1
  dname = File.dirname(ARGV[0])
  FileUtils.cd dname
  rootfile = File.basename(ARGV[0]).gsub(/\.tex$/,"")+".tex"
else
  $stderr.print "Usage:  cattex [textfile]\n"
  exit 1
end

ltx = Ltx.new(rootfile)

ltx.deep_each do |s|
  print s
end

