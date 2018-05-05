---
title: "An Error of GitLab Pages in Containers"
date: 2018-05-05T13:55:47+09:00
type: posts
draft: false
---

ここ数日自宅内サーバで GitLab の構築をしていました。
[LXD](https://linuxcontainers.org/ja/lxd/) を使って非特権のコンテナ内で構築していたのですが、[GitLab Pages](https://docs.gitlab.com/ce/user/project/pages/) の構築中にトラブルに遭遇しました。

Debian(stretch) 上で Omnibus パッケージを使ってインストールしているので、サービス構築の大部分は自動化されているのですが、いくつかの付随サービスには追加の設定が必要です。
マニュアルによれば、GitLab Pages では最小限の設定として

```
pages_external_url "https://example.io"
```

とすれば良いということになっていました。
しかしなにをどうやってもうまくいきません。503エラーがNginxから帰ってきます。

リバースプロキシを別途用意して運用する予定で、そこからアクセスしていたため、問題を切り分けに時間がかかり、手こずりました。直接アクセスしてみたり、いろいろ検証した結果、GitLab上のPages提供のためのHTTPサーバが止まっていて、その手前に組み込まれているリバースプロキシのみが動いているということがわかりました。

くわしくログをみてみると

```
2018-05-05_03:19:11.87022 time="2018-05-05T03:19:11Z" level=info msg="chroot failed" error="Can't copy \"/dev/urandom\" -> \"/tmp/gitlab-pages-1525490351852200041/dev/urandom\". operation not permitted"
2018-05-05_03:19:11.87032 time="2018-05-05T03:19:11Z" level=fatal error="Can't copy \"/dev/urandom\" -> \"/tmp/gitlab-pages-1525490351852200041/dev/urandom\". operation not permitted"
```

と書いてあるログが`/var/log/gitlab/gitlab-pages/current`で見つかります。

どうやらマニュアルには「シンプルなHTTPサーバ」と書いてあるくせに、派手にmknodしたりchrootしたりしてるようです。コンテナ内でのことなので、そんなシステムコールは通りません。そのため、サーバの起動に失敗しているようです。

コミットログによると、この変更は一週間ぐらい前に入ったもので、getrandom()が実装されていない古いLinuxカーネルを使っているシステムに対応するためのもののようです。<https://gitlab.com/gitlab-org/gitlab-pages/issues/10>

この問題への対処法として、`-daemon-inplace-chroot`[オプションが同時に追加されています](https://gitlab.com/gitlab-org/omnibus-gitlab/merge_requests/2483/commits)。設定ファイルに`gitlab_pages['inplace_chroot'] = true`と書き加えると、chrootをその場で行うようになり、デバイスファイルの作成を抑止できます。

この情報にたどり着くまでにソースコードみたりいろいろしましたけど、[リポジトリの Readme.md](https://gitlab.com/gitlab-org/gitlab-pages/blob/master/README.md) にコンテナ内での動作に触れている箇所があって、そこさえ見ていればこんなに時間使わずに済んだのに…　という気がします。