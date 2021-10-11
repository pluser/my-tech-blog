---
title: "LaTeX Cheatsheet"
date: 2020-11-26T00:48:15+09:00
type: posts
draft: false
summary: 卒論とか修論用のコピペで使えるLaTeXチートシートです
mathjax: true
---

卒論とか、修論とか、そういうの向けのLaTeXチートシートを書いていこうと思います。
とりあえず御託はいいから早急にTeX文書を書かなきゃいけないんだ！っていう人向けのなので、コピペですぐ使えるようにまとめてみます。

LaTeXにはマニュアルが標準で添付されています。`texdoc <パッケージの名前>`などとして読むことができるので、活用してみてください。

なお、この記事は適当に更新して項目を増やしたり、最新の状況に追従する予定です。

## 前提条件
LuaLaTeX の使用を前提にしています。一般的な普通にTeXをインストールすると、ほとんどの場合は導入済みになっていると思います。`lualatex --version`などとするとインストール済みかどうか確認できます。
LuaLaTeXはいままで広く使われてきたplatexなどと違い、PDFを直接生成できるため問題が起きにくく、日本語を含むUnicode文字を自然に扱えます。LuaLaTeXを使いましょう。

## プリアンブル
TeX文書のうち、`\begin{document}`より以前部分をプリアンブルと呼びます。用紙サイズとか、読み込むパッケージの指定、文書全体に関するような各種設定など……

```LaTeX
\documentclass[a4paper,lualatex,ja=standard]{bxjsarticle}
\usepackage[unicode,hidelinks,pdftitle={PDFのメタデータのタイトルを入力}]{hyperref}
\usepackage{amsmath}
\usepackage{graphicx}
\title{タイトルを入力}
```
### 文書クラス

TeXのドキュメントのサイズや余白などをコントロールするものを文書クラスと呼び、`\documentclass`で設定します。

`documentclass`は章立てのない文書については`bxjsarticle`がおすすめです。章立てのある文章は`bxjsreport`で。
日本語用の文書クラスなので、日本語のマニュアルが添付されています。詳しい使い方は`texdoc bxjsarticle`でどうぞ。
`article`や`jarticle`はもう古すぎるので、使うのを止めましょう。

### パッケージの読み込み
文書を書くにあたって、ほぼ確実に読み込むべきパッケージなどがあるので、紹介します。

#### hyperref
PDFのリンク機能を使うために必要なパッケージです。PDFで、引用番号をクリックした時に文献リストへジャンプしたり、節を分けた文書を作成した時に、目次用のリンク（対応したPDF
ビューアで見ると見出しが一覧できる）を設定してくれます。
そのまま使うと文書中のリンクに色が付いてしまうので、オプションに`hidelinks`を指定しておきましょう。

#### amsmath
アメリカ数学会謹製のパッケージです。数式の参照やフォントの調整など、数式にまつわるいろいろなことをしてくれます。
数式を扱うならば必須のパッケージです。

#### graphicx
外部の画像ファイルなどを読み込むためのパッケージです。

## 数式を書きたい

### ベクトルなど太字にしたい
`\boldsymbol{x}`と書きましょう。
もしくは、プリアンブルで`\usepackage{bm}`しておくと、`\bm{x}`で太字にできます。

`\mathbf{x}`でも太字にできるのですが、立体（非斜体）になってしまうので、変数には使用できません。

`\pmb{x}`も使用できますが、pmb は Poor Man's Bold の略で、要するに同じ文字をズラして2度印字することで太字にする、というなんとも無理やりな太字になります。そのためちょっと汚ない見た目になります。
もっとも、タイプライターが使われていた時代の太字は同じ文字の二度打ちだったそうなので、こちらが由緒正しい？太字になるのかもしれません。

### 行立ての数式を書きたい

```LaTeX
\begin{equation} \label{eq:phyeng}
E = mc^2
\end{equation}
```

`\begin{equation} ... \end{equation}` の代わりに `\[ ... \]`を使うこともできます。
数式環境中では改行は許されていないので注意。エラーになる。なお `eqnarray` は問題があるので使ってはいけません。また、環境の前に空白行が入ると別の段落という扱いになり、出力結果にも空行が入ってしまうので注意してください。

数式番号を振りたくない場合には`equation`の代わりに`equation*`を使う。
または、`mathtools`パッケージを読み込んだ後、`\mathtoolsset{showonlyrefs,showmanualtags}`とプリアンブルに書いておけば、未参照の数式番号は自動的に省いてくれるようになる。`equation`と`equation*`の使い分けを考えなくて済むようになる。

数式を参照するには、`\label{eq:hogehoge}`として参照名を付けておいて、文中で`\eqref{eq:hogehoge}`で参照できる。慣例的に数式の参照名は`eq:`で始めることが多い。

`\eqref`ではなく`\ref`で参照してしまうと、かっこを付ける機能などが働かないので注意。

複数行にまたがる数式などの詳しい使い方はマニュアルか、
https://tm23forest.com/contents/latex-amsmath-guide-with-svg-outputexample
を参照すると良いです。

### 行列の転置
いろいろな（場当たり的）対応がされている模様。意味論的にはメチャクチャ…… まあ数学の書式自体がメチャクチャなのでしかたがないのかも。
個人的には `A^\top` を使って \\( A^\top \\) としています。詳しくは以下を参照。

- [LaTeXでの転置行列の表記 - Alice in the Machine - Blog](https://blog.browniealice.net/post/latex_transpose/)
- [math mode - What is the best symbol for vector/matrix transpose? - TeX - LaTeX Stack Exchange](https://tex.stackexchange.com/questions/30619/what-is-the-best-symbol-for-vector-matrix-transpose)
- [TeXで転置行列を美しく出力する方法 | 理系のための備忘録](https://science-log.com/%E6%95%B0%E5%AD%A6/tex%E3%81%A7%E8%BB%A2%E7%BD%AE%E8%A1%8C%E5%88%97%E3%82%92%E7%BE%8E%E3%81%97%E3%81%8F%E5%87%BA%E5%8A%9B%E3%81%99%E3%82%8B%E6%96%B9%E6%B3%95/)

## 図を入れたい

### 数式入りの凝った図を作りたい
無料の範疇では [Inkscape](https://inkscape.org) を使うのがおすすめです。数式の入れ方は下記を参照。

- [InkscapeでLaTeX数式を使った図の作成 | tm23forest.com](https://tm23forest.com/contents/inkscape-pdflatex-equation-figure)

### SVG画像をそのまま貼りたい
まず [Inkscape](https://inkscape.org) が導入され、パスが通っていることが前提。
プリアンブルに

```LaTeX
\usepackage{svg}
\svgsetup{inkscapelatex=false}
```

と入れておいて、

```LaTeX
\begin{figure}
  \centering
  \includesvg[width=.7\linewidth]{figures/hogehoge.svg}
  \caption{hogehoge}
  \label{fig:hogehoge}
\end{figure}
```

などとして貼る。オプションなどは `\includegraphics` とほぼ同様。
プリアンブルの `\svgsetup{inkscapelatex=false}` は文字と図の位置関係がズレてしまうのを防ぐための設定。テキスト情報を保持したSVG画像では、特にスケーリング時に、テキストの位置関係を示すアンカーの設定不備やフォントの実質的大きさの違いなどが原因でテキストと図がズレてしまうことがある。この設定により、テキストのレンダリングがTeX側ではなく、inkscape側で行われるようになる。

### 画像・図の上にTikZで何か描きたい
例はsvgの場合。ピクセル画像の時には `\includesvg` ではなく `\includegraphics` にすべし。
`scope` を使って画像の上にレイヤーを作り大きさを画像と一致させることで、スケールした時にTikzで描いたものと画像との座標がズレないようにしている。
なお `scope` のオプションのx,yでは座標の基底ベクトルを指定している。

```LaTeX
\begin{tikzpicture}
  \node[anchor=south west] (image) at (0,0) {
    \includesvg[height=.6\textheight]{figure/experiment_network.svg}};
  \begin{scope}[x={(image.south east)},y={(image.north west)}]
    \draw[rounded corners, blue, thick] (0,.06) rectangle ++(.44,.42);
  \end{scope}
\end{tikzpicture}
```

## BibLaTeX編
参考文献とかで引用する時の方法thebibliography環境を使う方法など、いくつかある。よっぽど小規模な文章を書くとき以外はBibLaTeXが現時点で一番使いやすく、引用データベースの使いまわしもできるので、これを使おう。

[BibLaTeX+Biberの始め方 | tm23forest.com](https://tm23forest.com/contents/biblatex-biber-begin) を見るとざっと使い方が分かる。

```LaTeX
\usepackage{biblatex}
\addbibresource{main.bib}
\begin{document}
  \printbibliography[heading=none]
\end{document}
```

`heading=none` オプションでセクションタイトルを付けないようにする。Beamerとかだとおかしくなってしまうため。

### 脚注で引用したい
引用した文献の書誌情報を脚注に書けると便利だったりする。
基本的に `\cite{hogehoge}` の代わりに `\footcite{hogehoge}` を使えばよい。

### 脚注のスタイルをいじりたい
- [biblatex の標準スタイルの解説 - Qiita](https://qiita.com/shiro_takeda/items/81f2c50c28eccbec08be)
- [biblatex のオプションの解説 - Qiita](https://qiita.com/shiro_takeda/items/fac1351495f32c224a28)

を見るとよい。
なお、脚注に著者名＋タイトル＋年号を表示するには次のようにする。`citestyle=authortitle` で著者名とタイトルを表示することにしておいてから後ろに年号を付加する。

```LaTeX
\usepackage[citestyle=authortitle]{biblatex}
\usepackage{xpatch}
\xapptobibmacro{cite}{\setunit{\nametitledelim}\printfield{year}}{}{}
```

## Beamer編
プレゼンテーション用のPDFを出力できるBeamerを使うと、パワーポイントなどと違い、コードで記述できる。バージョン管理などとも相性が良いし、ブラックボックスが少なく、使いまわしも効く。

### 右下にスライド番号を表示したい
```LaTeX
\setbeamertemplate{footline}[frame number]
```

プリアンブルに挿入。これで解決だ。

### 数式のフォントが変
```LaTeX
\usefonttheme[onlymath]{serif}
```

をプリアンブルに入れよう。数式のみが見慣れたCMフォントになる。

### 日本語が豆腐になる
Beamerにはマルチバイト文字を扱うことを事前に知らせなければいけない。これをプリアンブルに挿入。

```LaTeX
\documentclass[unicode]{beamer}
```

### 参考文献が大きすぎて入らない
お手軽にはスライド自体を縮めてしまうのが良い。余白が大きくなるのではなく、きちんと右端まで文字が来るので心配は無用だ。

```LaTeX
\begin{frame}[shrink=50]{参考文献}
文献いろいろ
\end{frame}
```

などとしてフレームごと縮小してしまおう。

### 日本語を明朝体ではなくゴシック体にする
```LaTeX
\renewcommand{\kanjifamilydefault}{\gtdefault}
```
