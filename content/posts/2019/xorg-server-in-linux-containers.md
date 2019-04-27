---
title: "Xorg Server in Linux Containers"
date: 2019-04-27T22:41:25+09:00
type: posts
draft: false
summary: Linuxコンテナ(systemd-nspawn)上でデバイスファイルを使うための設定
---

セットアップの簡略化の目的で Linux Container を使って Arch Linux を使おうとしています。
Gentoo 上で Arch Linux を使うことで両方のディストリビューションの良いとこ取りができるのではないかと考えています。

ベースシステムである Gentoo Linux の上で systemd-nspawn を動かし (Gentoo では systemd を init システムとして選択できます)、そこで Arch Linux を動かすことでいろいろなソフトウェアをバイナリからインストールして使えるようにしつつ、環境のリサイクルなどを簡単にできるようにしようということです。

デスクトップとして使うために、nspawn 上の Arch Linux 上で xorg-server を動作させようとしています。
systemd-nspawn は chroot にネットワークやPIDなどの隔離機能を付け加えたようなものなので、それらの機能をオフにすることでファイルシステム隔離機能のみを使いたいのです。
具体的には、特権コンテナとして動作させ、かつネットワークを非プライベートに指定すればほぼ十分なのですが、そのままだとデバイスにうまくアクセスできません。

nspawnコンテナがたとえ特権モードで動作していても、デバイスファイルへのアクセスは別の機構で制限されるようです。
Xサーバーの動作に必要な tty0 や dri/card0 といったファイルも制限されてしまい、特権コンテナであってもそれらへのアクセス時には Operation not permitted エラーとなってしまいます。
この機構を制限するためには、それらデバイスファイルへのアクセスを許可する必要があります。
systemd-nspawn にはデフォルトでリソース制限がかけられており、この影響でデバイスへのアクセスができなくなっています。
`systemctl show systemd-nspawn@[machine name].service`
とすることで該当するsystemdサービスの現在有効な設定が表示されるのですが、その中で DevicePolicy が closed になっており、また必要なデバイスファイルが DeviceAllow に列挙されていません。

具体的には、
`systemctl edit systemd-nspawn@[machine name].service`
としてデフォルトの設定を上書きするためのファイルを開き、
```ini
[Service]
DeviceAllow=char-ttyS rwm
DeviceAllow=char-drm rwm
```
などと書き加えることでデバイスの使用を許可します。
あとはコンテナ起動時に `dev/tty0` など必要なファイルをマウントするか作成することでコンテナ内でデバイスを使用できるようになりました。

具体的にどのデバイスファイルを使うためにどういった記述が必要なのかは、
`man systemd.resource-control`
を見ると書いてありますので、詳細はそちらを見てください。
