#!/bin/sh
exec ruby -x "$0" "$@"
#!ruby

# ラベル名の表を表示する -l option
#   ラベル名、\labelコマンドで割り当てられている=1、\refコマンドで参照されている=1、\pagerefコマンドで参照されている=1
#
# ラベル名を振り直す。-m option
#
# texファイルを読んで、ラベルの振り直し（以下に示す）をする。
# 1. 参照されていないラベルを削除する。
#    参照されていないラベルとは、\label{}で定義されているが、\ref{}や\pageref{}で参照されていないラベルのことである。
#    当然ながら、削除するのは\label{ラベル名}の部分である。
# 2. ラベルを振り直す。
#    「label:1」、「label:2」のように、「label:」のプリフィックスをと通し番号を用いたラベル名に変更する

require "fileutils"
require "ltx"

# label data base
class Ldb
  def initialize
    @table = []
    @n = 0
  end
  def lookup lname
    @table.each do |r|
      if r[:name] == lname
        return r
      end
    end
    nil
  end
  def install lname, type
    @n += 1
    r = {name: lname, n: @n, label: 0, ref: 0, pageref: 0}
    increase r, type
    @table << r
  end
  def increase r, type
    r[type] += 1
  end
  def each
    @table.each do |r|
      yield r
    end
  end
end

def usage
  $stderr.print "Usage : label [-l|-m] [rootfile]\n"
  exit 1
end

if ARGV[0] == "--help"
  usage
elsif ARGV[0] == "-l"
  opt = :l
  ARGV.shift
elsif ARGV[0] == "-m"
  opt = :m
  ARGV.shift
else
  opt = :l # default
end
if ARGV.size == 0
  rootfile = "main.tex" # default name
elsif ARGV.size == 1
  dname = File.dirname(ARGV[0])
  FileUtils.cd dname
  rootfile = File.basename(ARGV[0]).gsub(/\.tex$/,"")+".tex"
else
  usage
end

ltx = Ltx.new rootfile
ldb = Ldb.new

bufstr = ""
ltx.deep_each do |s|
  s = s.gsub(/%.*$/,"")
  bufstr << s.gsub(/\\/, "\n"+"\\") #コマンドを別行に分離
end

verbatim = false
buf = []
bufstr.each_line do |s|
  if verbatim == false && s =~ /\\begin\s*\{verbatim\}/
    verbatim = true
  elsif verbatim == true && s =~ /\\end\s*\{verbatim\}/
    verbatim = false
  elsif verbatim == false
    buf << s
  end    
end

buf.each do |s|
  if s =~ /\\label\s*\{([^}]*)\}/
    lname = $1
    lflag = :label
  elsif s =~ /\\ref\s*\{([^}]*)\}/
    lname = $1
    lflag = :ref
  elsif s =~ /\\pageref\s*\{([^}]*)\}/
    lname = $1
    lflag = :pageref
  else
    next
  end
  record = ldb.lookup lname
  if record
    ldb.increase record, lflag
  else
    ldb.install lname, lflag
  end
end

if opt == :l
  print "name\tlabel\tref\tpageref\n"
  ldb.each do |record|
    print "#{record[:name]}\t#{record[:label]}\t#{record[:ref]}\t#{record[:pageref]}\n"
  end
elsif opt == :m
  ltx.backup # まずはバックアップの作成 .... 内容を書き換えた後では遅い

  ltx.deep_each do |s|
    t1 = ""
    t2 = s
    while t2 =~ /\\(label|ref|pageref)\s*\{([^}]+)\}/ do
      record = ldb.lookup $2
      raise "Something wrong. A label #{$2} is not in the table." unless record # record==nilだった場合は、何かがおかしい
      if record[:label] > 0 && record[:ref] == 0 && record[:pageref] == 0 #no reference => delete
        t1 = t1+$`
      else
        t1 = t1+$`+"\\#{$1}{label:#{record[:n]}}"
      end
      t2 = $'
    end
    s.replace t1+t2 #s=t1+t2ではなく、s.replace t1+t2であることに注意
  end
  ltx.write # 修正内容を書き出し（上書き）
end
