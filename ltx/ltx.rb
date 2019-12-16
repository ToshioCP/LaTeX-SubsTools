# ltx.rb

# メインファイル・・インスタンス生成時に与えられたファイル。このファイルからすべてのファイルはinputで取り込まれる。
# ルートファイル・・\begin{document},\end{document}を含むファイル。\documentclassを含んでいる（スクリプトでチェックはしていないが）
# サブファイル・・ルートファイルがinputコマンドで取り込むファイル 

# メインファイルはルートファイルの場合とサブファイルの場合がある。

# @ltx ハッシュの構造
# :f => ファイル名（LaTeXソースファイル）
# :b => バッファ。上記のファイルをreadlinesした配列
# :c => \inputコマンドで指定されたサブファイルを読み込んで作った（このハッシュと同種の）ハッシュの配列
# :cの部分は再帰的生成されてリストになる。
#  逆にそれにアクセスするには再帰呼び出しをすれば良い。

# その他のインスタンス変数
# @files ルートファイル、サブファイルの一覧（配列）

class Ltx
# ファイル名を指定して、LaTeXファイルをバッファに読み込む。
  def initialize(f)
    @files = [] # ファイル名の一覧
    @ltx = read_ltx f
  end
# writeは@ltxのバッファ（ルートファイル、サブファイルすべてを含む）の内容をそれぞれのファイルに上書きする。
# バックアップが必要な場合は、ユーザ側で事前にバックアップすること。
  def write
    write_sub @ltx if @ltx
  end
# 各ファイルのバックアップを行う
# ファイル名は sample.tex.bakのように.bak拡張子がつく。
  def backup
    backup_sub @ltx if @ltx
  end
# ルートファイルを先頭に、サブファイルの全部を加えたファイル名の一覧（配列）を返す。
  def files
    @files.dup
  end
# each メソッドには2つあり、deep_eachは\inputを実行し、shallow_eachは\inputを無視する。
# つまり、deep_eachはサブファイルも回るが、shallow_eachはルートファイルしか回らない。

# deep_eachメソッド。inputされるファイルの読み込み順に従い、下位ファイルも含める。そのとき\inputコマンドの行は消える。
# ただし、プリアンブルとポストドキュメント（\end{document}以降の部分）を除く
  def deep_each
    stat = :preamble
    @ltx[:b].each do |s|
      if stat == :preamble && s =~ /\\begin\{document\}/
        yield s
        stat = :body
      elsif stat == :body && s =~ /\\end\{document\}/
        yield s
        stat = :postdocument
      elsif stat == :body && s =~ /\\input\s*\{([^}"]+|"([^}]+)")\}/
        yield "%"+s
        subfile = $2 || $1
        @ltx[:c].each do |l|
          if l[:f] == subfile
            each_sub(l) {|s| yield s}
          end
        end
      else
        yield s
      end
    end
  end
# バッファの1行ずつ返すshallow_eachメソッド。inputは無視して、下位ファイルを読み込まない。
  def shallow_each
    @ltx[:b].each {|s| yield s} if @ltx
  end

private
  def read_ltx f
    if @files.find_index(f) != nil
      nil
    else
      @files << f
      ltx = {f: f, b: IO.readlines(f), c: []} # :f filename :b buffer :c child (LaTeX file)
      ltx[:b].each do |s|
        # sの中に複数のコマンドがあることを想定して、それらのコマンドを別の行に分解し、それぞれの行でコマンドをチェックする
        s.gsub(/\\/,"\n\\").each_line do |t|
          # \input{filename}
          # \input{"filename"}
          # この2つに対する動作は同じである。
          # このようにダブルクォートでファイル名を囲むことができる
          if t =~ /\\input\s*\{([^}"]+|"([^}]+)")\}/
            if $2
              l = read_ltx $2
            else
              l = read_ltx $1
            end
            if l # not nil
              ltx[:c] << l
            end
          end
        end
      end
      ltx
    end
  end
  def write_sub ltx # writeの下位ルーチン。リカーシブ。
    ltx[:c].each do |l|
      write_sub l
    end
    IO.write ltx[:f], ltx[:b].join
  end
  def backup_sub ltx # backupの下位ルーチン。リカーシブ。
    ltx[:c].each do |l|
      backup_sub l
    end
    IO.write ltx[:f]+".bak", ltx[:b].join
  end
  def each_sub ltx
    ltx[:b].each do |s|
      if s =~ /\\input\s*\{[^}]+\}/
        yield "%"+s
        s.gsub(/\\/,"\n\\").each_line do |t|
          if t =~ /\\input\s*\{([^}"]+|"([^}]+)")\}/
            subfile = $2 || $1
            ltx[:c].each do |l|
              if l[:f] == subfile
                each_sub(l) {|s| yield s}
              end
            end
          end
        end
      else
        yield s
      end
    end
  end
end
