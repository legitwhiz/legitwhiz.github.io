## 1. Git運用ルール

サイト管理のためのGit運用フローを作ってみました。

### 1.1. 目的
1. 複数人で効率的に共同作業ができるように最低限の操作を覚えてほしい ＋ 最低限のルールを決めたい
2. 納品ファイルの履歴を管理したい

### 1.2. 最低限の操作を覚える
↓をひと通り演習。
[Git をはじめからていねいに](https://github.com/takanabe/introduction-to-git)
基本的な操作が身につきます。より高度なことは都度身につけていけば良いです。
GUIクライアントソフトを使う前に上記でコマンド操作を演習しておくべきかと思います。

### 1.3. 最低限の運用フロー
![git-flow](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/git-flow.png)

| ブランチ名  | 説明     |
|:-----------|:---------|
| `master`                | メイン |
| `release`               | プレビュー・納品用 |
| `feature/[機能・作業名]`  | 作業用 |

* `master`と`release`ブランチを常駐
*  何か作業する時は`master`ブランチから`feature/[機能・作業名]`という名前でブランチを切りそちらで作業する。作業完了後masterへマージ。
* 一人作業かつ作業規模が小さい場合のみ`master`ブランチで作業してもよい
* masterへマージした後featureブランチは削除する。再作業時に都度同名ブランチを作るように
*  `master`→`feature`ブランチへのマージは適宜おこなう
*  作業がある程度終わりプレビュー、納品を行う段階に入ったら`master`→`release`へマージする
*  納品したリビジョンは`release`ブランチよりTagを付ける。`release/[YYYYMMDD（公開年月日）]/v[バージョン番号]`
*  一度納品データが完成しTagを付けた後、再修正・再納品が発生した場合、バージョン番号を上げてタグを付け直し古いバージョン番号のタグを削除する

### 1.4. READMEを書く
* リポジトリルートに必ずREADMEファイル（`README.md` OR `README.txt`）を置く
* READMEに書く内容は、

ビルドが不要な場合（HTML、CSS、JavaScriptなどのコーディングデータ）
  * リポジトリ内の納品フォルダの場所（パス）

ビルドが必要な場合（Jade、SCSS、AltJSなどから書き出す場合）
  * 納品データのビルド手順
  * リポジトリ内の納品フォルダの場所（パス）




### 1.5. 参考
[Git入門：Git初学習者のための効率的な学習方法を考えてみた](http://blog.takanabe.tokyo/2014/12/13/git%E5%85%A5%E9%96%80%EF%BC%9Agit%E5%88%9D%E5%AD%A6%E7%BF%92%E8%80%85%E3%81%AE%E3%81%9F%E3%82%81%E3%81%AE%E5%8A%B9%E7%8E%87%E7%9A%84%E3%81%AA%E5%AD%A6%E7%BF%92%E6%96%B9%E6%B3%95%E3%82%92%E8%80%83/)
[俺のオレオレgit-flow](http://www.songmu.jp/riji/entry/2014-02-10-git-ore-flow.html)



## 2. 事前準備(初期の構築時のみ実行)

git環境を使えるようにするため初期設定及びmaster,releaseブランチの作成



### 2.1. リポジトリ作成

ブラウザでGitbucketにアクセスし、[Sign in]からrootで入ります。

右上の[＋]を選択し、[New repository]をクリック 。

![new_repository001](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/new_repository001.png)



[Repository name]を入力し、[Description]にレポジトリの説明を入力し[Create repository]をクリック。

![new_repository002](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/new_repository002.png)



### 2.2. masterブランチ、releaseブランチの作成

```
git init
git remote add origin http://localhost:8080/git/root/SSO.git
vi README.md
git add README.md
git config --global user.name "Daisuke Sakamoto"      #username
git config --global user.email "sakamoto@aaabbb.com"  #email
git config --global core.editor vi                    #editor
git config --global merge.tool vimdiff                #diff tool
git config --list

git commit -m "first commit"
git push -u origin master
git checkout -b release
git push origin release
```

## 3.コマンドでのワークフロー
### 3.1. 準備

- ローカルのmasterに移動する

```
$ git checkout master
```

- ローカルのmasterをリモートと同期する

```
$ git pull origin/master
```

- masterから、作業用のブランチを作成する。

```
$ git checkout -b branchname master
```
    ※ブランチ名は担当者名と作業名をスラッシュで結合したものとする。
    例： taro/featurename, taro/bugname

### 3.2. コーディング

- コードを書く。
- コミットする。

```
$ git status
$ git add filename
$ git commit -m "コメント"
```

- 直前のコミットを取り消す場合：

```
$ git reset --soft HEAD
```

- コーディングとコミットを繰り返す。
  - コミットは頻繁に、どのような単位で行なっても良い。

  - コーディング中の更新履歴は汚くなっても良い。

- リモートのmasterに追随する(時々 and 最終テスト前)：

    - masterの更新を取得する。

```
$ git fetch origin/master
```

- masterの更新の内容を確認する。

```
$ git log --oneline--prety=medium -10 origin/master
```

- masterに更新に追随するためにrebaseする。

```
$ git rebase origin/master
```

- 作業を中断して他のブランチに移動する前に：
    - すべてコミットする。

```
$ git commit
```

- もしくは、一時保存する。

```
$ git stash "コメント"
```

- 他のブランチから戻ってきたら。

```
$ git stash list
$ git stash pop
```

- コーディング、テストを終え、他のメンバーに渡せる状態になったら、次の「マージ」に進む。

### 3.3. マージ
- 新機能の追加など、チーム内部で機能レビューが必要な場合は、ステージング環境にマージ、デプロイ、機能レビューする。
- バグや小さな変更など、機能レビューが不要な場合は、プロダクション環境にマージする。



### 3.4. プロダクション（master）

- masterに移動する。
```
$ git checkout master
```

- masterをリモートと同期する。
```
$ git pull origin/master
```

- 対象のブランチに移動する。
```
$ git checkout branchname
```

- masterに更新に追随するためにrebaseする。
```
$ git rebase master
```

- ステージングで機能テストしていた場合、devのみに適用されている更新が取り除かれるので、ローカルでテストする。 バグ等あれば、ローカルで修正する。
    - これによる変更がなかった場合は、マージへそのまま進んで良い。

- masterに移動する。
```
$ git checkout master
```

- masterにブランチをマージする。

```
$ git merge --squash branchname
$ git commit -m "コメント"
```

- リモートにmasterをpushする。

```
$ git push
```



### 3.5. リリース

- プロダクションへのデプロイは、責任者が更新内容を確認してから行う。

- masterに移動する。

```
$ git checkout master
```

- masterをリモートと同期する。
```
$ git pull origin/master
```

- 前回のデプロイ移行の、masterの更新履歴を確認する。

```
$ git log
```

- 必要に応じて、前回のデプロイ時との差分を確認する

- タグをつける。

```
$ git tag 2018.12.18
```

- プロダクション環境にデプロイする。

### 3.6. プロダクション（release）

- releaseに移動する。
```
$ git checkout release
```

- releaseをリモートと同期する。
```
$ git pull origin/release
```

- 対象のブランチに移動する。
```
$ git checkout branchname
```

- releaseに更新に追随するためにrebaseする。
```
$ git rebase release
```

- ステージングで機能テストしていた場合、devのみに適用されている更新が取り除かれるので、ローカルでテストする。 バグ等あれば、ローカルで修正する。
- これによる変更がなかった場合は、マージへそのまま進んで良い。

- releaseに移動する。
```
$ git checkout release
```

- releaseにブランチをマージする。
```
$ git merge --squash branchname
$ git commit -m "コメント"
```

- リモートにreleaseをpushする。
```
$ git push
```

- ブランチを削除する（しばらく待ったほうが良い？）。
```
$ git branch -D branchname
```



## 4. GUI Client

[TortoiseGit]と[Git for Windows]をWindows端末に導入しGUI環境を構築します。

なお、[TortoiseGit]は裏で[Git for Windows]を使用するため、先に入れておく必要があります。

### **4.1. [Git for Windows](https://git-for-windows.github.io/)**

1. [Git for Windows]にアクセスし、[Download]をクリック。

    ![Git_for_Windows001](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/Git_for_Windows001.png)

2. ダウンロードした、[Git-2.20.1-64-bit.exe]を実行する。

3. Setup画面で[Next]をクリック。

    ![Git_for_Windows002](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/Git_for_Windows002.png)

4. インストールするディレクトリを選択し、[Next]をクリック。

    ![Git_for_Windows003](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/Git_for_Windows003.png)

5. 必要なコンポーネントを選択し、[Next]をクリック。
    ​    最低限[Windows Exploere integration],[Git Bash Here],[Git GUI Here],[Git LFS]は必要かと


![Git_for_Windows004](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/Git_for_Windows004.png)


6. スタートメニューフォルダーを入力し、[Next]をクリック。

    ![Git_for_Windows005](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/Git_for_Windows005.png)

7. 使用するエディタを選択し、[Next]をクリック。

    ![Git_for_Windows006](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/Git_for_Windows006.png)

8. 環境変数では[Use Git from Git Bash only]を選択し、[Next]をクリック。
     ここで[Use Git from the Windows Command Prompt]にしてしまうと、
       コマンドプロンプトがGitBashに乗っ取られて非常に使いづらくなる。


![Git_for_Windows007](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/Git_for_Windows007.png)




9. HTTPS接続時に使用するSSLコンポーネントは、[Use the OpenSSL library]を選択し、[Next]をクリック。

    ![Git_for_Windows008](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/Git_for_Windows008.png)

10. 改行コードの変換動作については、勝手に改行コードを変えてほしくないので[Checkout as-is, commit as-is]を選択し、[Next]をクリック。

    ![Git_for_Windows009](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/Git_for_Windows009.png)

11. ターミナルエミュレータの選択は、[Use MinTTY]を選択し、[Next]をクリック

    ![Git_for_Windows010](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/Git_for_Windows010.png)

12. その他のオプションについては特に変更せず、[Install]をクリック

    ![Git_for_Windows011](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/Git_for_Windows011.png)

13. [Finish]をクリック

    ![Git_for_Windows012](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/Git_for_Windows012.png)



### **4.2. [TortoiseGit](https://tortoisegit.org/)**
※languagePackもココにあります。

1. ブラウザで[TortoiseGit]にアクセスし[Download]をクリック。

![TortoiseGit_Install001](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/TortoiseGit_install001.png)

2. 端末の環境に合わせて[for 32-bit Windows]もしくは[for 64-bit Windows]を選択しダウンロードする。

![TortoiseGit_Install002](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/TortoiseGit_install002.png)

3. 日本語パッケージをダウンロードするために、以下の[JapaneseのSetup]をクリック。

![TortoiseGit_Install003](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/TortoiseGit_install003.png)

4. ダウンロードした[TortoiseGit-2.7.0.0-64bit.msi]を実行し、インストールウィザードで[Next]をクリック

![TortoiseGit_Install004](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/TortoiseGit_install004.png)

5. ライセンス情報を一読し[Next]をクリック

![TortoiseGit_Install005](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/TortoiseGit_install005.png)

6. SSHクライアントは[TortoiseGitPlink...]を選択し[Next]をクリック

![TortoiseGit_Install006](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/TortoiseGit_install006.png)

7. インストール先はそのままにし、[Next]をクリック

![TortoiseGit_Install007](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/TortoiseGit_install007.png)

8. [Install]をクリック

![TortoiseGit_Install008](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/TortoiseGit_install008.png)

9. チェックを外し[Finish]をクリック

![TortoiseGit_Install009](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/TortoiseGit_install009.png)

10. 日本語化パッケージである[TortoiseGit-LanguagePack-2.7.0.0-64bit-ja.msi]を実行。

![TortoiseGit_Install010](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/TortoiseGit_install010.png)

11. セットアップが完了したら[Configure TortoiseGit to use this language]にチェックを入れ、セットアップを完了する。

![TortoiseGit_Install011](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/TortoiseGit_install011.png)

### 4.3. 公開鍵の生成

GUIクライアントから公開鍵認証によるSSH接続を行うため、事前にクローン先コンピューターにて公開鍵を生成する。

1. プログラム一覧のTortoiseGitの中にある"PuTTYgen"を起動し、キー生成を開始する。

   ![TortoiseGit_Install012](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/TortoiseGit_install012.png)



2. 上部のゲージがいっぱいになるまで、空白部分上でマウスカーソルを動かす。

   ![TortoiseGit_Install013](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/TortoiseGit_install013.png)

3. 公開鍵が生成されて表示されるので、すべてコピーしておく。その後[Save private key]を押して秘密鍵の保存ダイアログを開く。[Key passphrese]にパスフレーズを入力することで、秘密鍵にパスワードを掛けることができるが今回は空白としている。

![TortoiseGit_Install014](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/TortoiseGit_install014.png)

4. パスフレーズをかけていない場合警告が出るが、無視して"はい"で進める。

​      適当な場所に保存する。ファイル名も任意で良い。

![TortoiseGit_Install015](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/TortoiseGit_install015.png)



## 5. GUIクライアントでのワークフロー

### 5.1 準備

#### ローカルリポジトリの設定

1. ローカルリポジトリを作成するディレクトリを適当なところに作成し、エクスプローラーからディレクトリを右クリックし[Git ここにリポジトリを作成]をクリック。

![git_clone001](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/git_clone001.png)

2. チェックはそのまま(外れた状態)にして[OK]ボタンをクリック

![git_clone002](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/git_clone002.png)

3. [OK]ボタンをクリック

![git_clone003](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/git_clone003.png)

#### リモートリポジトリの同期

1. ローカルリポジトリのディレクトリを右クリックし、[Git 同期]をクリック。

![git_clone000](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/git_clone000.png)

2. リモートブランチに[master]を入力し、リモートの[管理]ボタンをクリック。

![git_clone004](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/git_clone004.png)

3. URLを入力し[新規に追加/保存]をクリックし、[OK]ボタンをクリック

![git_clone005](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/git_clone005.png)

4. Git同期画面で[プル]ボタンをクリックし"成功"となることを確認し、[閉じる]ボタンをクリック。

![git_clone006](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/git_clone006.png)



#### ブランチを切る

1. エクスプローラーでローカルリポジトリのディレクトリを右クリックし、[TortoiseGit]-[ブランチを作成]をクリック。

![git-flow_gui_branch001](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/git-flow_gui_branch001.png)



2. ブランチを作成画面で[ブランチ]にブランチ名を入力し、[新しいブランチに切り替える]にチェックを付け、説明に改修内容を入力し、[OK]ボタンをクリック。

   ブランチ名は、"<作業者の名前>/<改修内容>"とする。

![git-flow_gui_branch002](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/git-flow_gui_branch002.png)



Gitコマンド実行中画面で"成功"と出力されたことを確認し、[閉じる]ボタンをクリック。

![git-flow_gui_branch003](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/git-flow_gui_branch003.png)



### 5.2 コーディング

1. 追加(add)

ローカルリポジトリに対象ファイルをコピーし、エクスプローラーで対象ファイルを右クリックし、[TortoiseGit]-[追加]をクリック。

![git-flow_gui001](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/git-flow_gui001.png)



追加終了画面で成功となっていることを確認し、[OK]をクリック。

![git-flow_gui002](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/git-flow_gui002.png)



エクスプローラーで追加した対象ファイルのアイコンに＋マークが付けば追加(add)された状態となります。

![git-flow_gui003](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/git-flow_gui003.png)



2. commit

追加した対象ファイルを右クリックし、[Gitコミット]をクリック。

![git-flow_gui004](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/git-flow_gui004.png)



コミット画面でメッセージを入力し、[著述日時を設定する]、[作者を設定]にチェックを入れ、[コミット]ボタンをクリック。

![git-flow_gui005](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/git-flow_gui005.png)



Gitコマンド実行中画面で"成功"と出力されたことを確認し、[閉じる]ボタンをクリック。

![git-flow_gui006](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/git-flow_gui006.png)



ファイルのアイコンが＋マークからチェックマークに変わればCommitされた状態となります。

![git-flow_gui007](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/git-flow_gui007.png)



### 5.3 マージ

- 新機能の追加など、チーム内部で機能レビューが必要な場合は、ステージング環境にマージ、デプロイ、機能レビューする。

- バグや小さな変更など、機能レビューが不要な場合は、プロダクション環境にマージする。



### 5.4 プロダクション(master)



1. marge

エクスプローラーでローカルリポジトリディレクトリを右クリックし、[TortoiseGit]-[切り替え]をクリック。

![branch_marge001](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/branch_marge001.png)



ブランチを選択し、プルダウンメニューから"master"を選択し、[OK]をクリック。

![branch_marge002](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/branch_marge002.png)



Gitコマンド実行中画面で"成功"を確認し、[閉じる]ボタンをクリック。

![branch_marge003](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/branch_marge003.png)



エクスプローラーでローカルリポジトリディレクトリを右クリックし、[TortoiseGit]-[マージ]をクリック。

![branch_marge001](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/branch_marge001.png)



ブランチを選択し、[...]ボタンを押す

![branch_marge004](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/branch_marge002.png)



左ペインから[refs]-[heads]-[<ブランチ名の/区切りで前半部分>]を選択し、右ペインから[<ブランチ名の/区切りで後半部分>]を選択し、[OK]ボタンをクリック。

![branch_marge005](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/branch_marge005.png)



ブランチに5.1で作成したブランチ名が記載されていることを確認し、[OK]ボタンをクリック。

  ![branch_marge006](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/branch_marge006.png)



Gitコマンド実行中画面で"成功"が出力されたことを確認し、[閉じる]ボタンをクリック。

![branch_marge007](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/branch_marge007.png)



1. push

エクスプローラーでローカルリポジトリディレクトリを右クリックし、[TortoiseGit]-[プッシュ]をクリック。

![git-flow_gui008](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/git-flow_gui008.png)



[ローカル]で[master]を選択し、[リモート]で[master]を選択し、[OK]をクリック。

![git-flow_gui009](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/git-flow_gui009.png)



Git Credential Manager for WindowsでGitBucketのユーザ、パスワードを入力し、[OK]をクリック。

![git-flow_gui010](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/git-flow_gui010.png)



Gitコマンド実行中画面で"成功"を確認し、[閉じる]ボタンをクリック。

![git-flow_gui011](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/git-flow_gui011.png)



### 5.5. リリース

1. pull

エクスプローラーでローカルリポジトリディレクトリを右クリックし、[TortoiseGit]-[ログを表示]をクリック。

![release_pull001](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/release_pull001.png)



リモートで"origin"を選択し、リモートブランチで"master"を選択し、[OK]ボタンをクリック。

![release_pull002](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/release_pull002.png)



Gitコマンド実行中画面で"成功"を確認し、[閉じる]ボタンをクリック。

![release_pull003](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/release_pull003.png)





2. log

エクスプローラーでローカルリポジトリディレクトリを右クリックし、[TortoiseGit]-[ログを表示]をクリック。

![release_log001](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/release_log001.png)



出力されたログメッセージを確認する。

![release_log002](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/release_log002.png)



3. tag

エクスプローラーでローカルリポジトリディレクトリを右クリックし、[TortoiseGit]-[タグを作成]をクリック。

![release_tag001](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/release_tag001.png)



タグにタグ名を入力し、メッセージにタグの詳細を入力し、[OK]ボタンをクリック。

![release_tag002](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/release_tag002.png)



### 5.6. プロダクション(release)



1. pull

エクスプローラーでローカルリポジトリディレクトリを右クリックし、[TortoiseGit]-[プル]をクリック。

![release_brunch_pull000](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/release_brunch_pull000.png)



リモートを選択し、リモートブランチで[release]を選択し、[OK]をクリック。

![release_brunch_pull001](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/release_brunch_pull001.png)



Gitコマンド実行中画面で"成功"と出力されていることを確認し、[閉じる]をクリック。

![release_brunch_pull002](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/release_brunch_pull002.png)



2.marge

エクスプローラーでローカルリポジトリディレクトリを右クリックし、[TortoiseGit]-[マージ]をクリック。

![release_brunch_marge001](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/release_brunch_marge001.png)



ブランチで"remote/origin/release"を選択し、[OK]をクリック。

![release_brunch_marge002](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/release_brunch_marge002.png)



Gitコマンド実行中画面で"成功"と出力されていることを確認し、[閉じる]をクリック。

![release_brunch_marge003](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/release_brunch_marge003.png)

3. push

エクスプローラーでローカルリポジトリディレクトリを右クリックし、[TortoiseGit]-[プッシュ]をクリック。

![release_brunch_push001](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/release_brunch_push001.png)



[ローカル]で[master]を選択し、[リモート]で[release]を選択し、[OK]をクリック。

![release_brunch_push002](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/release_brunch_push002.png)



Gitコマンド実行中画面で"成功"を確認し、[閉じる]ボタンをクリック。

![release_brunch_push003](https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/release_brunch_push003.png)



以上

