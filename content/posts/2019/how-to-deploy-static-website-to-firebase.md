---
title: "How to Deploy Static Site to the Firebase"
date: 2019-11-05T06:11:50+09:00
type: posts
draft: false
summary: "CI で Firebase Hosting へデプロイする方法"
---

このブログサイトは（この記事を書いている時点では） Static Site Generator である [Hugo](https://gohugo.io/) を使って Markdown のソースからブログサイトを生成しています。さらに生成物を Google の [Firebase](https://firebase.google.com/) の Hosting サービスに送信して公開し、Google に通知を送って検索エンジンへのインデックスを促しています。

これらの手続きを CI システムを使って自動化しています。今回はその手順について紹介します。

現在、CI では Docker コンテナを使って環境をクリーンに保つことが一般的に行われていますが、こちらの CI システムの都合で、コンテナなどを使わずネイティブ環境になっています。実のところ、この CI サーバ自体が仮想化されたインフラに乗ってるので、さらにコンテナを使ってネストさせるのがめんどくさいんです。どうせ CI システムは自分一人しか使わないので、コンテナを使うよりネイティブに使った方がアップデートとかもしやすいという面もあります。

まず、環境構築ですが、`hugo` はワンバイナリなので、どこでも動きます。適当に用意しましょう。たいていのディストリビューションならパッケージが用意されているでしょう。
次に `firebase-tools` のインストールが必要です。これは Javascript 製なので `nodejs` が動く必要があります。Google の GCP 用のツールは Python2 製なので、これが使えないかと思っていたのですが、firebase が GCP に統合されつつあるとはいえ、GCP の Storage からは Firebase Hosting のファイルがうまく見えませんでした。仮にファイルがうまく見えても、Firebase Hosting にできて GCP Storage のホスティング機能にできないこともあるので、まあ素直に Firebase のツールを使うことにしました。

あとは普通に build ステージで hugo を実行すると public ディレクトリに生成物ができます。
次に deploy ステージで public ディレクトリの内容を送信します。
`FIREBASE_TOKEN` という環境変数名で Firebase へのアクセストークンを CI システムに設定しておいて、`firebase use --token ${FIREBASE_TOKEN} <プロジェクト名>`などとしてプロジェクトを指定します。プロジェクト名は Firebase コンソールに書いてあります。次に `firebase deploy -m "Pipeline ${CI_PIPELINE_ID}, build ${CI_BUILD_ID}" --non-interactive --token ${FIREBASE_TOKEN}` としてデプロイします。簡単ですね。
最後の仕上げとして Google へサイトマップを送信します。`curl http://www.google.com/ping?sitemap=<サイトマップへのURL>` です。

最後に CI システムが GitLab だった時の設定ファイルを参考に書いておきます。TravisCI とかでもほとんど同じかと思います。ただし、ツールのインストールプロセスとかが事前に必要だと思いますが…

```yaml
stages:
  - build
  - deploy

build:
  stage: build
  variables:
    GIT_SUBMODULE_STRATEGY: recursive
  script:
    - hugo
  artifacts:
    paths:
      - public
  only:
    - master

deploy:
  stage: deploy
  cache:
    paths:
      - node_modules/
  script:
    - firebase use --token ${FIREBASE_TOKEN} <PROJECT_NAME>
    - firebase deploy -m "Pipeline ${CI_PIPELINE_ID}, build ${CI_BUILD_ID}" --non-interactive --token ${FIREBASE_TOKEN}
    - curl http://www.google.com/ping?sitemap=https://blog.pluser.net/sitemap.xml
  environment:
    name: production
    url: https://blog.pluser.net
  only:
    - master
```