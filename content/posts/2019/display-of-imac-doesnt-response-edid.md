---
title: "Display of iMac Doesn't Response EDID"
date: 2019-04-28T03:39:50+09:00
type: posts
draft: false
summary: "iMacでLinuxを起動するとディスプレイの表示が壊れる現象への対処"
---

Intel GPU を積んだ Apple の iMac で Linux を起動すると画面表示が壊れてしまいます。
起動時のカーネルパラメータで `nomodeset` などを渡すと表示の崩壊を回避できますが、GPUアクセラレーションなども同時に無効になってしまうため、根本的な解決策にはなりません。

こうなってしまう原因は iMac のディスプレイが EDID をうまく返さないためのようです。
原因が分かってしまえば対処は簡単で、カーネルに対して適当な EDID を注入することで回避できます。

Linux カーネルにはあらかじめ「標準的な」EDID が添付されているため、それを読み込むように指定すれば基本的にはOKです。
詳しくは [KMS-モードの強制とEDID](https://wiki.archlinux.jp/index.php/Kernel_Mode_Setting#.E3.83.A2.E3.83.BC.E3.83.89.E3.81.AE.E5.BC.B7.E5.88.B6.E3.81.A8_EDID) を見てもらえばいいのですが、要するにカーネルパラメータとして `drm_kms_helper.edid_firmware=edid/1920x1080.bin` などと渡すと組込みの EDID を使ってくれるということです。

これでディスプレイ表示は正常になり、KMSもまともに動作するようになりました。
