---
title: "NixOS on Raspberry Pi 4"
date: 2024-01-13T22:04:04+09:00
type: posts
mathjax: false
category: ""
---

NixOS という Linux ディストリビューションがあります。ここではあまり深くは話しませんが、OS の設定ファイルやパッケージなどを Nix 言語という関数型言語(雰囲気は Jsonnet)で定義して生成するようになっています。基本的に全ての設定ファイルが Nix 言語で記述されて生成される(そしてルートファイルシステムは読取り専用になる)ため、プロビジョニングが非常に楽だったり、設定ミスがあった場合にロールバックが容易にできるというメリットがあります。

Raspberry Pi 4 で構成されたクラスタを作るにあたって自前でプロビジョニングするため、今回は NixOS を採用してみることにしました。鬼門だったのは NixOS のインストールで、今回はその手順を書いておこうと思います。

途中まで [Installing NixOS on a Raspberry Pi @ nix.dev](https://nix.dev/tutorials/nixos/installing-nixos-on-a-raspberry-pi) の手順に従います。ただ、Raspberry Pi の SD カードに OS を入れるとパフォーマンスに大きな影響があることと、SD カードの寿命がかなり減ることが経験的に分かっているので、今回は SSD にインストールすることにしました。Raspberry Pi 4 には M.2 スロットなどというオシャレなものは無いので最近発売された超小型 USB 接続の SSD(SSD-PST1.0U3-BA) を使うことにしました。

最近の Raspberry Pi 4 は USB からのブートに出荷時の状態で対応しているため、ファームウェアのアップデートなどは不要でした。まずは手順に従って SD カードにインストーラを書き込みます。

Raspberry Pi には HDMI 端子が付いていますが、キーボードとモニターを接続したくはないので、インストーラにあらかじめ SSH 公開鍵を入れておき、ブートした段階で SSH できるようにします。
ちなみに今回の環境は Raspberry Pi に PoE hat を載せているのでイーサネットケーブル一本で済む構成になっています。

SD カードにある第二パーティションをマウントすると `/nix` などいくつかのディレクトリが見えると思います。この SD カードから起動すると `/etc` など標準的な Linux のディレクトリ構造が生成されますが、一度も起動していない状態では寂しい内容になっています。

ここでは root でログインできるようにするために、`/root/.ssh/authorized_keys` ディレクトリとファイルを作成し、公開鍵を書き込んでおきます。パーミッションの設定も忘れずに。ディレクトリとファイルは root ユーザー以外の閲覧を禁じておく必要があります。

インストーラには OpenSSH のサービス設定が既に含まれているため、サービスの起動設定などをする必要はありません。

準備ができたら SD カードを Raspberry Pi に挿入して電源を投入します。

イーサネットケーブルが接続されていれば DHCP から IP アドレスを取得してくれます。ホスト名は `nixos` なので何らかの手段で DHCP から割り当てられた IP アドレスを探り当ててください。
自分の環境では DHCP 割り当てと同時に FQDN が DNS に登録されるので適当にアクセスするだけでした。

SD カードに書き込んだ公開鍵に対応する秘密鍵を指定して ssh アクセスしたら、上のドキュメントで書かれている通りにディスクにパーティションを切ってフォーマットします。自分は第一パーティションにブートローダとカーネルを置き、第二パーティションに `/` ファイルシステムを置くことにしました。スワップパーティションは作らないことにしました。第二パーティションを ext4 でフォーマットしたのでスワップを作るにしてもファイルにしようと思います。

後は手順の通りに作成したファイルシステムを /mnt にマウントし、/mnt/boot もマウントしておきます。そのまま `sudo nixos-generate-config --root /mnt` を実行すると `/mnt/etc/nixos/{configuration.nix,hardware-configuration.nix}` が生成されるので適当に編集します。ひとまず自分のアカウントを設定して SSH ログインできるようにします。

```nix
{
  services.openssh.enable = true;

  users = {
    mutableUsers = false;
    users."USER_NAME" = {
      isNormalUser = true;
      password = "password";
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAB362c...R4mo1Na MEMO"
      ];
    };
};
```

NixOS には外部の設定をインポートする機能があるので、Raspberry Pi 用のハードウェア設定をインポートすると固有のハードウェアに対応するドライバを簡単に導入できます。
[よく知られたハードウェア設定をまとめたリポジトリ](https://github.com/NixOS/nixos-hardware)があるので、README.md の通りに設定します。

まずインストーラ上でリポジトリを登録します。

```terminal
$ sudo nix-channel --add https://github.com/NixOS/nixos-hardware/archive/master.tar.gz nixos-hardware
$ sudo nix-channel --update
```

続いて Raspberry Pi の設定を読み込むように `hardware-configuration.nix` を編集します。

```nix
imports = [
  <nixos-hardware/raspberry-pi/4>
];
```

このままだとブートパーティション上にブートローダがインストールされないので、インストーラが入っている SD カードのブートパーティションから U-Boot のバイナリと device tree blob ファイルをコピーしてください。ブートパーティションの内容を全てコピーすれば OK です。

ちなみにブートローダとして systemd-boot をインストールしてみたりしたのですが、手元の環境ではなぜかカーネルがフリーズしてしまい、うまくいきませんでした。こだわりが無ければインストーラに含まれている U-Boot をコピーしてしまうのが一番簡単なようです。

最後に `nixos-install` を実行すると設定ファイルに基づいて NixOS がインストールされます。このコマンドは冪等なので何度実行しても大丈夫です。`configuration.nix` に問題があるとエラーになるので適宜修正してください。

最後に `poweroff` して SD カードを抜き、起動してください。

おつかれさまでした。SSH でアクセス可能な状態で立ち上がってくるので、あとは一般的な NixOS と同じように扱えば大丈夫です。
