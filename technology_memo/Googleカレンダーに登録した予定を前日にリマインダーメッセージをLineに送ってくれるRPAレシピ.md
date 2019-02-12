# Googleカレンダーに登録した予定を前日にリマインダーメッセージをLineに送ってくれるRPAレシピ

**【RPA】**とは、【Robotics Process Automation】の略称で繰り返し実行されるアクションをロボットが自動で実行することを差す。

特に活用されているのが企業で、日々繰り返し行われる業務をロボットが変わりに行ってくれるというものです。働き方改革の一環としても注目されている技術です。

ですが、業務だけでなく日常生活であってもロボットで自動化することも可能なんですよ。

企業が使用している**【RPA】**ツールは、複雑なこともできますがツールのお値段もそれなりにします。ですが、フリーのツールもありますし、スマホアプリでもあるんです。

また、プログラミングを必要とするツールもあれば、GUIで簡単に作れるモノもあるようです。

## じゃあ、なにを自動化したら便利？

Googleカレンダーに予定を登録しておいても、近々の予定ならいいんですが、先の予定だと折角カレンダーに予定をいれておいても見ることを忘れたなんて経験ありませんか？

なので、カレンダーに登録した予定を前日にリマインダーとしてLINE通知する**【RPA】**を作ってみようと思います。

### 【材料】

1. GoogleカレンダーとGoogle Apps Scriptを使うためのアカウント

2. 通知する先としてLINEアカウント

3. LINE メッセージを発行するLine

後は、愛情があれば…w

### 【作り方】

#### 前菜

まずは、前菜に自分のGoogleアカウントを使って『Googleカレンダー』にスケジュールを作ってみたいと思います。

##### 1． PCでもスマホでも簡単にできますので手順は省略します。

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/linenotify/google_calender_TEST_Schedule.png" width="420">



#### 汁物

次にLINEにメッセージを発行するためのLINE Notifyと呼ばれるAPIトークンを作ります。
ブラウザで以下のURLにアクセスします。この手順はPCより実施すること。

[LINE Notify](https://notify-bot.line.me/doc/ja/)

##### 1. 右上の「ログイン」ボタンを押し、

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/linenotify/line_notify_01.png" width="420">

##### 2. アカウントのメールアドレスとパスワードを入力し「ログイン」ボタンを押します。

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/linenotify/line_notify_02.png" width="420">

3. 「登録サービス管理」を押す。

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/linenotify/line_notify_03.png" width="420">


##### 4. 「サービスを登録する」を押す。
<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/linenotify/line_notify_04.png" width="420">



##### 5. 必要事項を入力し「登録」ボタンを押す。

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/linenotify/line_notify_06.png" width="420">

##### 6. LINE Notifyのトップ画面に戻り「トークンを発行する」ボタンを押す。

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/linenotify/line_notify_07.png" width="420">



##### 7. 出力された文字列を控えればAPIトークンの出来上がりです。



#### 主食

メインディッシュは、Google Apps Script(GAS)で定期的にGoogleカレンダーを見て明日の予定があれば、LINEメッセージを送るスクリプトを作ってみたいと思います。



##### 1. Googleドライブにアクセスし、[MyDrive]を右クリックして、[More] →[Connect more apps]をクリック

※既に[Google Apps Acript]を登録済みの場合は、手順5.に進む

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/linenotify/GAS_01.png" width="420">





##### 2. [Google Apps Acript]をクリック

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/linenotify/GAS_02.png" width="420">



##### 3. [connect]をクリック

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/linenotify/GAS_03.png" width="420">

##### 4. 了承確認画面で[OK]をクリック

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/linenotify/GAS_04.png" width="420">



##### 5. [My Drive]を右クリックして、[Google Apps Acript]をクリック

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/linenotify/GAS_05.png" width="420">



##### 6. スクリプトを入力

※スクリプトの内容は、[【LINE Notify + GoogleAppsScript + Googleカレンダーで明日の予定を絶対忘れない】](https://qiita.com/imajoriri/items/e211547438967827661f)を参考にさせていただきました。

ただし、予定がない日に「予定がありません」とLINEメッセージが来るのは寂しいので何もメッセージを出さないようにしています・・・www



<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/linenotify/GAS_06.png" width="420">



##### 7. [File]→ [Save]をクリック

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/linenotify/GAS_07.png" width="420">



##### 8. トリガー画面で[トリガーを追加]をクリック

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/linenotify/GAS_08.png" width="420">



##### 9. トリガー追加画面で[実行する関数を選択]で「myFunction※1」を選択。

※先程、入力したスクリプトのメイン関数が「myFunction」となっているため。

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/linenotify/GAS_09.png" width="420">



##### 10. [時間ベースのトリガーのタイプを選択]で「日付ベースのタイマー」を選択し、[時刻を選択]で[午前8時～9時]を選択し[保存]をクリック。時間はお好みで。

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/linenotify/GAS_10.png" width="420">



##### 11. トリガーが登録されたことを確認し、終わりです。

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/linenotify/GAS_11.png" width="420">


#### 最後に

今回は、Googleカレンダーの予定を通知するものを作りましたが、色々なAPIを使用してLINE等に通知することができそうなのが分かりました。
それこそ、今まで一つ一つ欲しい情報のあるサイトを閲覧していたところを本当に必要な情報だけをピックアップすることも可能になりそうですので、余計な時間短縮を目標に色々と試してみたいと思います。