function scraping() {
  var url = "https://www.s-n-p.jp/kishou.htm"
  //アクセストークンを設定
  var token = ["fkRf9pBD9UOvmuBloFxwuWeCrGROMbqV094RI8Blyiu"];

  var response = UrlFetchApp.fetch(url);

  //LINE Notifyに送るリクエストを設定
  var options =
   {
     "method"  : "post",
     "payload" : "message=" + response.getContentText(),
     "headers" : {"Authorization" : "Bearer "+ token},
   };

   //リクエスト送信
   UrlFetchApp.fetch("https://notify-api.line.me/api/notify",options);
}