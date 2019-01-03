---
title: "Flutter を Emacs で自動ホットリロードする"
date: 2018-12-26T20:04:28+09:00
type: posts
draft: false
summary: "Emacs でも他の IDE 同様保存時の自動リロードに対応したい！"
---

先日、クロスモバイルアプリケーションフレームワークの Flutter バージョン1.0 が発表されました。
クロスプラットフォームのモバイルアプリ開発を体験してみよう、ということで触りはじめています。

ところで、この Flutter は特長の一つとして、ホットリロードに対応しています。つまり、内部の状態を変更することなく、仮想端末上で稼働中のアプリケーションを再読み込みできます。CLI から使う場合には、アプリケーションを `flutter run` して起動するのですが、この端末上で `r` キーを押すことで端末上のアプリケーションが0.5秒前後でホットリロードされます。このため、ファイルを変更してすぐにアプリケーションを試すことができます。しかも状態が保存されたままなので、アプリケーションの再起動と違って目的の画面に行き着くために何度も同じ操作をする必要がありません。

このホットリロード機能、Android Studio などの Flutter 用の IDE ならばファイルに変更を保存した時点で自動的に行なわれるのですが、その他の IDE やエディタでは変更の度に一々CLI端末に戻って `r` キーを押す作業が必要になります。

一回あたりは僅かな手間ですが、何回もとなるとこれは面倒です。できればエディタでもIDEのように保存時点でホットリロードしてもらいたいのです。

Flutter のホットリロードを制御しているプログラムは `flutter_tool` という名前で、実はこのプログラムに `SIGUSR1` シグナルを与えることで外部からホットリロードをトリガーできます。[github/Flutter](https://github.com/flutter/flutter/blob/6d6ada14a0b76f01f5867530949131fdfd0525a0/packages/flutter_tools/lib/src/commands/run.dart#L130)

ここまで分かれば後は簡単で、Emacs の場合は保存時フックで、`flutter_tool` へシグナルを送るようにするだけです。

具体的には、

```emacs-lisp
(defun init/flutter-hot-reload()
	(interactive)
	"Send a signal to daemon to hot reload."
	(start-process "emacs-flutter-hot-reloader" nil "pkill" "-SIGUSR1" "-f" "flutter_tool"))
(defun init/flutter-hot-reload-enable()
	(interactive)
	"Enable flutter hot reload on save."
	(add-hook 'after-save-hook 'init/flutter-hot-reload t t))
(defun init/flutter-hot-reload-disable()
	(interactive)
	"Disable flutter hot reload on save."
	(remove-hook 'after-save-hook 'init/flutter-hot-reload t))
(add-hook 'dart-mode-hook 'init/flutter-hot-reload-enable)
```

のようなコードを `init.el` に仕込むと良いでしょう。
これで dart-mode ではファイル保存時に自動的に Flutter がホットリロードされるようになるはずです。

ちなみに、Flutterではホットリロードではなくリスタート(状態を忘れる)が必要な場合もあるようですが、その場合は `SIGUSR2` を送れば良いようです。
