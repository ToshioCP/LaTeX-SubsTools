#!/bin/sh
exec ruby -x "$0" "$@"
#!ruby

# ind - indent a LaTeX source file.
#

# Indents can be nested deeper in each environment.
# The length of the indent can be specified (default is 4).
# $ ind -2 file  => The length is 2.

# Remark!
# \begin{...} and \end{...} need to be located in the different lines.
# If they appear in the same line, this script doesn't work correctly (ignores \end{...}).

length=4
if ARGV[0] =~ /-[[:digit:]]/
  length = ARGV.shift.to_i*(-1)
end
if ARGV.size != 1
  $stderr.print "Usage:  indent [-indent] texfile\n"
  $stderr.print "Example: indent -8 texfile\n"
  exit 1
end

buf=[]
n = 0
indent = 0

bname = File.basename(ARGV[0]).gsub(/\.tex$/,"")
texfile="#{bname}.tex"

IO.read(texfile).each_line do |s|
  s = s.gsub(/^\p{Blank}*/,"") # remove preceding spc or tab. \p{Blank} is the same as [[:blank:]] in Posix.
  t = s.gsub(/%.*$/,"") # remove comments
  n += 1
  if t =~ /\\begin\{(.+)\}/ # at the beginning of a new environment
    s.insert 0, " "*indent*length
    indent += 1
  elsif t =~ /\\end\{(.+)\}/ # at the end of the environment
    indent -= 1
    if indent < 0
      raise "Something wrong in the correspondance of begin and end at line #{n}.\n"
    end
    s.insert 0, " "*indent*length
  else
    s.insert 0, " "*indent*length
  end
  buf << s
end
if indent != 0
# for debug
#  IO.write "#{filename}.log", buf.join
  raise "Something wrong in the correspondance of begin and end at line #{n}.\n"
end
IO.write("#{texfile}.bak", IO.read(texfile))
IO.write(texfile,buf.join)
