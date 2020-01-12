---
title: "A Memorandom about Matplotlib"
date: 2020-01-12T06:23:52+09:00
type: posts
draft: false
---

## デフォルト値を恒久的に変更したい
`matplotlibrc` というファイルを作って書いておけばデフォルトのパラメータを指定しておける
詳しいやりかたは[公式ドキュメント](https://matplotlib.org/tutorials/introductory/customizing.html#the-matplotlibrc-file)が参考になる．


## 出力画像の背景色を白にする
matplotlib の出力する画像は，規定だと背景色が透明になっている（透明度をサポートしている画像形式の場合）．
なので，例えば背景が白でない環境，たとえば背景色が暗色の Jupyter Notebook などでは，軸や数字などの黒い線が非常に見辛くなってしまうことがある．
背景色を白で塗り潰すには，
`plt.rc('figure', facecolor='w')`
などとすると良い．その他，保存時のみの指定などは [StackOverflow の質問](https://stackoverflow.com/questions/29571179/set-ipython-notebook-inline-plots-background-not-transparent)を参照のこと．


## 画像解像度を指定する
ラスタ形式の画像で出力する場合，解像度が不足してしまうことがある．
`plt.savefig('filename.png', dpi=300)`
などのように，出力メソッドは `dpi` パラメータを受け付ける．
[StackOverflowの質問](https://stackoverflow.com/questions/39870642/matplotlib-how-to-plot-a-high-resolution-graph)を参照のこと．


## 折れ線・散布図のグラフの色を変更したい
デフォルトの色はかなり見辛く，色弱の人にはなおのこと区別しづらい．
デフォルトのグラフの色は，有名な可視化ソフトの配色テーブルをそのまま使っているらしい．
色の組み合わせは
`plt.rcParams['axes.prop_cycle']`
で分かる．また，色パレットを直接指定できる．[](https://oku.edu.mie-u.ac.jp/~okumura/python/color.html)を参考にするとよい．

さらに手軽に，グラフのスタイルを指定するのも良い．
[公式マニュアル](https://matplotlib.org/tutorials/introductory/customizing.html)が参考になる．"color blind" と書かれたスタイルを選んでおくと良い．
`plt.style.use('presentation')`
でスタイルを指定できるが，気を付けなければいけないのは，スタイルは「重ねがけ」できるということ．
複数回指定したばあい，前のスタイルによって定義された差分しか適用されない．（たとえデフォルトスタイルを適用してもリセットされない）
この重ねがけをリセットするには，デフォルトのパラメータを読み込みなおせば良い．
`matplotlib.rcParams.update(matplotlib.rcParamsDefault)`
[StackOverflowでの質問](https://stackoverflow.com/questions/26413185/how-to-recover-matplotlib-defaults-after-setting-stylesheet)が参考になった．
