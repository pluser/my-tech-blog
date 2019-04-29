---
title: "How to Use Apple Magic Trackpad 2"
date: 2019-04-28T12:49:14+09:00
type: posts
draft: false
summary: "Magic Trapckad 2 を Linux で使う時に、タッチ感度が非常に悪くなってしまう問題への対処"
---

通常、LinuxデスクトップではBluetooth、USB接続のマウスやキーボードは接続するだけで使えます。
Xサーバーでどのようなドライバによって処理されているのかはディストリビューションや選択に依りますが、現時点ではモダンなシステムでは libinput を使用しているはずです。

しかし、Apple の Magic Trackpad 2 (外付けのやつ) を libinput 経由で使おうとすると、タッチ感度が非常に悪くなってしまうという現象に遭遇してしまいました。
つまり、結構強く「押し込みながら」触らないとマウスカーソルが動いてくれません。
これは Magic Trackpad 2 の「くせ」らしく、まともに使うためには設定が必要でした。

```ini
[Touchpad pressure override]
MatchName=*Magic Trackpad 2
AttrPressureRange=2:0
```
という内容のファイルを `/etc/libinput/local-overrides.quirks` に作成する必要がありました。
後で libinput 本体の方で改善されるらしいですが、それまでの間はユーザーが自分で調整する必要がありそうです。

[Reddit - Now that the Magic Trackpad 2 is being supported.](https://www.reddit.com/r/linux/comments/a0zxav/now_that_the_magic_trackpad_2_is_being_supported/)

を参考にしてください。

ちなみに `Apple Inc. Magic Trackpad 2: kernel bug: Touch jump detected and discarded.` というエラーメッセージがXサーバーのログに溢れるようになりますが、これといった実害は無いので放置しています。そのうち修正されるといいな。
