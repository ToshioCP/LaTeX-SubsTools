#!/bin/sh
exec ruby -x "$0" "$@"
#!ruby

# Usage : reset [rootfile]
# This script restores LaTeX files (mainfile and subfiles).
# That is, it copies file.tex.bak to file.tex and overwrites it.

require "fileutils"
require "ltx"

if ARGV.size == 0
  rootfile = "main.tex" # default name
elsif ARGV.size == 1
  dname = File.dirname(ARGV[0])
  FileUtils.cd dname
  rootfile = File.basename(ARGV[0]).gsub(/\.tex$/,"")+".tex"
else
  $stderr.print "Usage : reset [rootfile]\n"
  exit 1
end

ltx = Ltx.new rootfile
files = ltx.files
files.each do |f|
  if File.exist? f+".bak"
    IO.write(f, IO.read(f+".bak"))
  end
end

