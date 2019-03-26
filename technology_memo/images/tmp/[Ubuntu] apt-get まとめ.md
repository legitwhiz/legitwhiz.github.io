---
layout: default
title: [Ubuntu] apt-getコマンド Summary
---
# [Ubuntu] apt-getコマンド Summary
## 古い`apt-get`コマンド

|コマンド|内容|
|:---|:---|
|`apt-get install [package]`|パッケージのインストール/更新|
|`apt-get update`|パッケージリストの更新|
|`apt-get upgrade`|インストールされてるパッケージの更新|
|`apt-get dist-upgrade`|インストールされてるカーネルの更新(Ubuntu)/ディストリビューションの更新(Debian)|
|`dpkg -l [package]`|インストールされてるパッケージの一覧|
|`dpkg -L`|インストールした時のファイルの一覧|
|`apt-cache search [query]`|パッケージの検索|
|`apt-cache policy [query]`|パッケージの検索 (インストール可能なバージョンの表示）|
|`apt-cache madison [query]`|パッケージの検索 (インストール可能なバージョンの一覧）|
|`apt-get remove [package]`|パッケージの削除|
|`apt-get autoremove`|使ってないパッケージの削除|
|`apt-get purge [package]`|パッケージの削除（設定ファイルも）|
|`apt-get clean`|アーカイブファイルの削除|
|`apt-get autoclean`|使ってないパッケージのアーカイブファイルの削除|


## 新`apt`コマンド

|コマンド|内容|
|:---|:---|
|`sudo apt update`|リポジトリ一覧を更新<br>( リポジトリ追加・削除時には必ず実行すること )|
|`sudo apt upgrade`|パッケージを更新<br>(通常のパッケージ更新時はこのコマンドを使用する)|
|`sudo apt full-upgrade`|パッケージを更新<br>(保留されているパッケージを更新するときに使用する)|
|`sudo apt autoremove`|更新に伴い必要なくなったパッケージを削除<br>(`apt`実行時にこのコマンドを実行するよう表示されたら実行する)|
|`sudo apt install {パッケージ名やdebファイルのパス}`|パッケージやdebファイルをインストール|
|`sudo apt remove {パッケージ名}`|パッケージを削除|
|`sudo apt remove --purge {パッケージ名}`|パッケージを__完全削除__|
|`sudo apt show {パッケージ名}`|パッケージの詳細情報を表示|
|`sudo apt list {パッケージ名}`|パッケージを検索(完全一致)|
|`sudo apt search {パッケージ名}`|パッケージを検索(部分一致)|
|`cat /var/log/apt/history.log`|`apt`コマンドの使用履歴を表示|
|`sudo apt autoclean`|キャッシュされているが、インストールはされていないdebファイルを削除|
|`sudo apt clean`|キャッシュされている全てのdebファイルを削除|
|`echo "{パッケージ名} hold"` &#124; `dpkg --set-selections`|パッケージをアップデート対象から除外|
|`echo "{パッケージ名} install"` &#124; `dpkg --set-selections`|パッケージをアップデート対象に戻す|



