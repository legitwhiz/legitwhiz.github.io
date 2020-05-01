# NextCloudをWindows10でネットワークマウント(WebDAV)

NetxtCloudをWindows10にて、ネットワークマウント(WebDAV)するための設定をやってみました。
エクスプローラでPCを開き、エクスプローラの右上の下矢印を押すと以下のようなメニューが出力されます。
出力されたメニューの中から「ネットワークの場所の追加」を押します。

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/WebDAV/webdav001.png" width="640">

「ネットワークの場所の追加」ウィザード起動するので、「次へ」をクリックします。

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/WebDAV/webdav002.png" width="640">

次の画面で「カスタムのネットワークの場所を選択」を選択し、「次へ」をクリックします。

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/WebDAV/webdav003.png" width="640">



NextCloudのWeb画面にアクセスし、設定を押すと下部にWebDAVのURLが出力されるので、コピーしておきます。



<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/WebDAV/webdav004.png" width="240">

次の画面で「インターネットまたはネットワークのアドレス」に先ほどコピーしておいたURLを貼り付け、「次へ」をクリックします。

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/WebDAV/webdav005.png" width="640">

次の画面で名前を入力し(デフォルトでドメイン名が入力されています)、「次へ」をクリックします。

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/WebDAV/webdav006.png" width="640">

次の画面で名前が表示されたら、「完了」をクリックします。

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/WebDAV/webdav007.png" width="640">

そうするとユーザ、パスワード認証画面が出力され入力するとWebDAV接続され、ネットワークの場所に追加されます。

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/WebDAV/webdav008.png" width="640">

