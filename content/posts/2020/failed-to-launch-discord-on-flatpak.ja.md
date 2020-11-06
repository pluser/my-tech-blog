---
title: "FlatpakのDiscordが動かない"
date: 2020-11-06T22:55:38+09:00
type: posts
draft: false
---

タイトルの通り。Flatpak上のDiscordが動かない。
起動はするもののメイン画面が開かず、ずっとスプラッシュスクリーンが出続ける現象。
コンソールから`flatpak run com.discordapp.Discord`とやって出力を見てみると、
ERR_CERT_AUTHORITY_INVALID とか言っているので、どうやら証明書回りで何か問題が起きている
らしい。

すったもんだ調べた末、`p11-kit`で知られるパッケージがバグっているらしい。
[issue](https://github.com/p11-glue/p11-kit/issues/275)が報告されていて、次のバージョンからは修正されているっぽい。

もし、p11-kitのバージョンが0.23.19ならばこの問題に当たっているので、適宜アップデートなり野良ビルドなりして避けられたし。
