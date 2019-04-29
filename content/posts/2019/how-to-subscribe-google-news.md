---
title: "How to Subscribe Google News"
date: 2019-04-29T16:15:11+09:00
type: posts
draft: false
summary: "Google News を RSS/Atom フィードで取得する方法"
---

[Google News](https://news.google.com/) のフィードを購読しようとしています。
しかしヘッダーにはRSSフィードの情報が無く、購読に必要な URI が分かりません。

どうやら購読したい画面の URL 語尾に `rss` や `atom` を付けることでフィードを返してくれるようです。
たとえばトップページの情報をRSSフィードとして取得したければ `https://news.google.com/atom` を購読すれば良いようです。

ただし、このままだと英語版の Google News になってしまいます。日本語版を取得するためには、`gl=JP` などのクエリを付加して `https://news.google.com/atom?gl=JP` などとすれば良いようです。

この `gl=JP` は Google のサービスに共通するスイッチで、「対象を指定された地域に絞る」という意味があるようです。
また `hl=ja` というものもあり、こちらはUI言語などを指定するようです。ほとんどの Google サービスで共通して使えるようなので、覚えておくと何か良いことがあるかも。
