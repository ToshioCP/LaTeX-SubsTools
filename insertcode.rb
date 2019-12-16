#!/bin/sh
exec ruby -x "$0" "$@"
#!ruby

# insertcode.rb

# LaTeXソースファイル中に
# %insertcode{プログラムのソースファイル名}
# という行があったときに、そのプログラムコードを読み込んでLaTeXソースファイル中に展開し、合わせてverbatim環境をセットする。
# プログラムのソースファイル名はそのLaTeXソースファイルのあるディレクトリからの相対ディレクトリ
#
# 例
# sample.rb
# print "Hello world.\n"
#
# LaTeX ファイル
# ... 文章 ...
# %insertcode{sample.rb}
# ... 次の文章 ...
#
# ===>>>
#
# ... 文章 ...
# \begin{verbatim}
# print "Hello world.\n"
# \end{verbatim}
# ... 次の文章 ...
#
# これを、LaTeXだけで解決するのは難しい。
# verbatim環境の中ではコマンドが利かないためである。

# Usage: insertcode texfile

# ファイル名に.bak拡張子をつけたバックアップを作成する
# %insertcodeを取り込んだコードで置き換えて、引数で与えられたファイル（texfile）に上書きする

require 'fileutils'

if ARGV.size == 0
  texfile = "main.tex" # default name
elsif ARGV.size == 1
# LaTeXのソースファイルの中のファイル名は、そのファイル（texfile）からの相対ディレクトリなので、カレントディレクトリをセットする
  dname = File.dirname(ARGV[0])
  FileUtils.cd dname
  texfile = File.basename(ARGV[0]).gsub(/\.tex$/,"")+".tex"
else
  $stderr.print "Usage : insertcode texfile\n"
  exit 1
end

buf_texfile = IO.read(texfile)
buf = ""
buf_texfile.each_line do |s|
  if s =~ /^%insertcode\{([^}]+)\}/
    buf += s
    buf += "\\begin{verbatim}\n"
    buf += IO.read($1)
    buf += "\\end{verbatim}\n"
  else
    buf += s
  end
end
IO.write("#{texfile}.bak",buf_texfile)
IO.write(texfile, buf)


