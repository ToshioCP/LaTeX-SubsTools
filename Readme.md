# SubsTools

## SubsTools作成の背景

#### LatexToolsとSubsToolsの関係

大きな文書、例えば100ページを越える本などをLaTeXで作る場合は、小さい文書の作成と異なる様々な問題を考える必要がある。

- ソースファイルの分割
- 分割コンパイル
- 文書の一括置換
- 前処理（LaTeXコンパイル前に処理する作業）

これらを支援するツール群がLatexToolsであり、いくつかのグループに別れている。

- BuildTools。ソースファイルの新規作成、ビルド、分割コンパイルを支援するツール群
- SubsTolls。ソースファイルに対する一括置換をするツール群

このように、SubsToolsはLatexToolsを構成する一部である。
SubsToolsは、「Substitution Tools」を短くしたものであり、一括置換のスクリプトを集めたものである。
個々のスクリプトの間にほとんど関連はない。
また、このツールに含まれるスクリプトは体系的に構成されたものではなくて、一括置換の例を示したものである。
書籍を書いていて、一括置換をしたいときには、執筆者が置換のスクリプトを新たに書かなければんらないことが多い。
その時にこれらのスクリプトが参考になると思う。
スクリプトは長くても150行程度であるので、要領さえ分かればスクリプトの記述は短い時間で書くことが可能である。
このドキュメントではSubsToolsを解説する。

#### ソースファイルの分割

LaTeXソースファイルを単にここではソースファイルと呼ぶ。
大きな文書を1つのソースファイルに記述するのは適切でない。
なぜなら、ファイルが大きくなると、エディタで編集するのが極めて困難になるからである。
そこで、文書を分割することになる。
通常は\\begin{document}と\\end{document}を含む1つのファイルと、そのファイルから\\includeまたは\\inputで呼び出される複数のファイルに分割する。
前者をルート・ファイル、後者をサブ・ファイルという。
\\includeと\\inputはどちらもサブ・ファイルの取り込みのコマンドだが、違いがある。

- \\includeは多段階の取り込みはできない。\\includeonlyで一部のみを取り込む指定ができる。取り込む前に\\clearpageをする。
- \\inputは単にファイルを取り込むだけで\\clearpageなどはしない。多段階の取り込みがでいる

SubsToolsでは、\\inputコマンドのみをサポートしており、\\includeコマンドはサポートしていない。
BuildToolsは\\inputと\\includeの両方をサポートしている。
両ツールにそのような違いがあるので注意してほしい（将来は両方共\\includeをサポートすべきではないかとは思っている）。

## LaTeXソースファイルの書き方

### 書き方のルールを作ることの重要性

LaTeXのソースファイルは、その文法に従っていればどう書いてもコンパイルは成功する。
例えば、

    \begin{center}abcde\end{center}

と書いても

    \begin{center}
      abcde
    \end{center}

と書いてもコンパイルの結果は同じである。

ただ、どちらかに統一したほうが書き手にとって利益がある。
上記の例をとってみよう。
仮に文書内のすべてのセンタリングを左寄せに変えたくなったとする（ありそうもないことだが、説明のための例なのでお許し頂きたい）。
もしも前者のように1行内に書いていれば、

    $ sed 's/\\begin{center}\(.\+\)\\end{center}/\\begin{flushleft}\1\\end{flushleft}/g'

などとスクリプトを書けば、機械的に変換できてしまう。
常に前者のスタイルでセンタリングを書いていれば文書内の全てのセンタリングを左寄せに変更することが可能である。
もしも常に後者のスタイルで記述している場合は、sedでは難しいかもしれないが、rubyやperlなどのスクリプトで変換できるだろう。
実際に筆者はeqnarray環境をすべてalign環境に直す作業をrubyスクリプトで行った。
この方法は作業が簡略になるだけでなく、正確にもなる。
（なお、eqnarry環境の問題点についてはインターネット上に多くの指摘がある）。

いくつか、筆者の使っているスタイルを記述すると、

- texファイルには拡張子.texをつける
- ルートファイル名はmain.texにする
- プリアンブルの記述はhelper.texというファイルに記述しinputコマンドでmain.texに取り込む
- 表紙はcover.texに記述する（titlepage環境で取り込む）
- 章ごとにサブファイルを作る
- ファイルの取り込みはinputコマンドのみを使い、includeコマンドは使わない
- ファイル名に日本語文字を使わない（synctexで不具合があったと記憶しているが、現在もそうなのですか？）
- 環境は、\\begin{...}と\\end{...}で各1行使い、その間に環境の内容を書く
- マクロを書く時に、展開される内容にinput,includegraphicsなどのファイルをとりこむ命令を書かない。

### マクロを記述する時の注意

前項の例を考えてみよう。
センタリングをすべて左寄せにするというスクリプトである。
もしもマクロ定義の中にセンタリングが含まれていたらどうなるか。
例えば

    \newcommand{\sample}{\begin{center}\textbf{This is a sample.}\end{center}}

というマクロ定義があったとしよう。
本文中に

    \sample

というコマンドがあると

    \begin{center}\textbf{This is a sample.}\end{center}

に展開される。
センタリングを左寄せに変えるスクリプトはnewcommandの内容を書き換えてくれれば、このマクロは無事に左寄せのマクロになってくれる。

別のスクリプトを考えてみよう。

    grep '\\begin{center}.\+\\end{center}' | wc -l

これは、本文中にセンタリングがいくつあるのかを数えるスクリプトである。
これは\\sampleという新たに定義されたコマンドをカウントしないので、スクリプトの結果は正しくない。

このようにマクロがスクリプトに対して上手く動作しないような副作用をもたらすことがある。
前項で、筆者のスタイルに「マクロを書く時に、展開される内容にinput,includegraphicsなどのファイルをとりこむ命令を書かない」とあるが、これはそういう副作用を避けるためのものである。

## ルートファイルとサブファイルの両方を一括置換する場合の方法

Ltxクラスは\\inputコマンドを用いてファイルを連結するので、一括置換にも使えそうだがすべきではない。
なぜなら、同一のファイルを複数ヶ所で\\inputで取り込んでいる場合、複数回置換してしまうからである。
たいていはそれは期待したものとは異なる結果をもたらす。
正しくは、次の方法を用いる。

- tfiles -a コマンドを使う
- Ltxクラスのfilesメソッドを使う

シェルスクリプトならば前者、Rubyプログラムならば後者が記述しやすい。
ただし、上記の2つの方法には違いがある。

- tfiles -a はボディで取り込まれるサブファイルとメインファイルの名前を返す
- Ltxクラスのfilesメソッドはすべてのサブファイルとメインファイルの名前を返す（プリアンブルのサブファイルも含まれる）

1つのファイルに対して一括置換をするスクリプトを、ルートファイルとサブファイル全体に作用させるシェルスクリプトとしてeveryがある。

    $ every script [rootfile]

これで、ルートファイルとサブファイルの両方に対してscriptによる一括置換をする。

## SubsTools のツール

    $ cattex [rootfile]

rubyスクリプト。
ルートファイルに\\inputコマンドが現れると、それをコメントアウトし、そこにサブファイルを読み込んで挿入する。
そのようにして\\inputコマンドをサブファイルで置き換えた文書を標準出力に出力する。
linuxのcatコマンドが複数のファイルをつなげて出力するように、cattexコマンドはルートファイルとサブファイルを\\inputコマンドにそってつなげて出力する。
どちらかというと、Ltxクラスのテスト用である。

    $ every 'script' [rootfile]

ルートファイルとボディのサブファイルのすべてについて、スクリプトを実行する。
スクリプトに引数をつける場合は、クォートで囲む。
このスクリプトによって、一つのファイルに対する一括置換はルートファイルとボディのサブファイル全体に対する一括置換に延長することができる。
注意：プリアンブルのサブファイルに対してはスクリプトを実行しない。
なぜなら、大抵の一括置換はボディのみを対象とすることがほとんどであるから。

例を下記に記す。

    $ every indent '-2' sample.tex

このスクリプトはsample.texとそのサブファイルに対して、

    indent -2 file

を実行する。fileは各ファイルのファイル名である。


    $ indent [\-indent] texfile

rubyスクリプト。
環境の中にインデントをつけるスクリプト。
空白の数は、ネストに応じて増えていく。
デフォルトのインデント長は4。
ltx.rb（後述）が必要。
オリジナルファイルはバックアップになり、.bak拡張子がつく。
引数は1つのみ。

    $ insertcode texfile

LaTeXファイルにプログラムコードを挿入するrubyスクリプト。
バックアップファイルを作成する。
texfileの中に

    %insertcode{sample.rb}
    ... ここに何か行があっても良い（初期状態では通常何もない） ...
    %end_insertcode

（sample.rbはプログラムコードのファイル名の例）
とあると、この2行の間がverbatim環境とプログラムコードに置き換えられる。

    %insertcode{sample.rb}
    \begin{verbatim}
    ... sample.rbの内容 ...
    \end{verbatim}
    %end_insertcode

ファイルはバックアップされた後に上書きされる。

    $ label [-l|-m] [rootfile]

ルートファイルとサブファイルのラベルの一覧を表示（-lオプション）、またはラベルの振り替え（-mオプション）をする。
振り替えをすると、「label:1」「label:2」などのように、「label:」のプリフィックスと数字の組み合わせの形にすべてのラベルは書き換えられる。
このとき、数字はかならずしも連続した自然数になるわけではない。
また、定義（labelコマンド）のみで参照（refまたはpagerefコマンド）がないラベルは削除される（-mコマンド）。
-mコマンドでは、ファイルのバックアップが作られる。

    $ revert rootfile

rubyスクリプト。
そのLaTeXファイルのメインファイルとサブファイルのすべてのバックアップファイル（が存在したら）を元のファイルにコピー上書きして、元の状態にもどす。
例えば、main.tex.bakの内容をmain.texに上書きする。
そして、そのサブファイルがsub.texだとすると、sub.tex.bakの内容をsub.texに上書きする。
サブファイルの検索は、main.texから行い、main.tex.bakから行うのではない。

### ltxパッケージ

rubyのLtxクラスを定義してあるパッケージである。requireして取り込む。

    require 'ltx'
    ltx=Ltx.new rootfile

で、ルートファイル、サブファイルの全部を取り込む。
ただし、\\include命令には対応していない。\\input命令のみ対応。
これを使うと、一括置換などを比較的簡単に作ることができる。

詳細は、Ltxフォルダにあるreadme.txtを参照。

## インストールとアンインストール

インストール用のスクリプト install.sh を使う。

    $ bash install.sh

この場合、\$HOME/binにスクリプトは保存される。
debianでは、ログイン時に\$HOME/binがあれば、実行ディレクトリのパス\$PATHに追加される。
インストール時に新規に \$HOME/bin を作成した場合には、再ログインしないと、それが実行ディレクトリに追加されないので注意が必要。
rootになってインストールすると /usr/local/bin にインストールされる。

    # bash install.sh

オプションで個人レベルのインストールか、システムレベルのインストールかを指定することも可能。

- -s システムレベル。/usr/local/bin にインストール。書き込み権限が必要。通常はrootになってインストールを実行する。
- -u ユーザレベル。 \$HOME/bin にインストール。rootでインストールすると/root/binにインストールされるので注意。つまり、rootの個人用としてインストールされる。これはおそらくありあえないインストールだと思う。通常はrootでないユーザでインストールを実行する。

アンインストールは uninstall.shで行う。

    $ bash uninstall.sh

または、

    # bash uninstall.sh

rootになって、システムレベルのアンインストール。
オプション -s, -u で、システムレベルか、個人レベルかを明示することも可能。
