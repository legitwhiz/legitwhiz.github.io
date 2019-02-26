//Todays_fortune.gs
//API仕様書 : http://jugemkey.jp/api/waf/api.php

function myFunction() {


  //今日の日付をAPIパラメータ用にバラバラに取得
  var date = new Date();
  var dateY = Utilities.formatDate( date, 'Asia/Tokyo', 'yyyy');
  var dateM = Utilities.formatDate( date, 'Asia/Tokyo', 'MM');
  var dateD = Utilities.formatDate( date, 'Asia/Tokyo', 'dd');
  var ymd = dateY + '/' + dateM + '/' + dateD;
  Logger.log('date:' + date);
  var jApi = 'http://api.jugemkey.jp/api/horoscope/free/' + dateY + '/' + dateM + '/' + dateD;
  Logger.log('jApi:' + jApi);

  //APIをfetchする
  var response = UrlFetchApp.fetch(jApi);
  var json=JSON.parse(response.getContentText());
  Logger.log('jApi:' + jApi);

  //[牡羊座:0][牡牛座:1][双子座:2][蟹座:3][獅子座:4][乙女座:5][天秤座:6][蠍座:7][射手座:8][山羊座:9][水瓶座:10][魚座:11]
  var seiza = 4;

  //イケてない記述ですが、配信内容を取得
  var content = '占いの内容 -- ' + json["horoscope"][ymd][seiza]["content"];
  var item = 'ラッキーアイテム -- ' + json["horoscope"][ymd][seiza]["item"];
  var money = '金運（5段階） -- ' + json["horoscope"][ymd][seiza]["money"];
  var total = '総合運（5段階） -- ' + json["horoscope"][ymd][seiza]["total"];
  var job = '仕事運（5段階） -- ' + json["horoscope"][ymd][seiza]["job"];
  var color = 'ラッキーカラー -- ' + json["horoscope"][ymd][seiza]["color"];
  var love = '恋愛運（5段階） -- ' + json["horoscope"][ymd][seiza]["love"];
  var rank = 'ランキング -- ' + json["horoscope"][ymd][seiza]["rank"];
  var sign = '星座 -- ' + json["horoscope"][ymd][seiza]["sign"];

  //イケてない記述ですが、メールに送信する本文を指定してます
  var contents = sign + '\n' + rank + '\n' + content + '\n' + total + '\n' + money + '\n' + job + '\n' + love + '\n' + item + '\n' + color;

  Logger.log('占いの内容 -- ' + json["horoscope"][ymd][seiza]["content"]);
  Logger.log('ラッキーアイテム -- ' + json["horoscope"][ymd][seiza]["item"]);
  Logger.log('金運（5段階） -- ' + json["horoscope"][ymd][seiza]["money"]);
  Logger.log('総合運（5段階） -- ' + json["horoscope"][ymd][seiza]["total"]);
  Logger.log('仕事運（5段階） -- ' + json["horoscope"][ymd][seiza]["job"]);
  Logger.log('ラッキーカラー -- ' + json["horoscope"][ymd][seiza]["color"]);
  Logger.log('恋愛運（5段階） -- ' + json["horoscope"][ymd][seiza]["love"]);
  Logger.log('ランキング -- ' + json["horoscope"][ymd][seiza]["rank"]);
  Logger.log('星座 -- ' + json["horoscope"][ymd][seiza]["sign"]);

  var address = 'ここに送信するアドレスを指定します！';
  var title = ymd + 'の占いです';
  //GmailApp.sendEmail(address, title, contents);
  LineSendFunction(title, contents)

}

function LineSendFunction() {
  // LINE Notifyのアクセストークン
  var key = "fkRf9pBD9UOvmuBloFxwuWeCrGROMbqV094RI8Blyiu";
  var url = "https://notify-api.line.me/api/notify";

  // LINE Notifyに送るメッセージ
  var msg = "";
  // 予定がない時
  if(tomorrowEvent.length === 0){
    msg = "明日の予定はありません。";
  }
  // 予定がある時
  else{
    msg += title + "\n\n";
    msg += contents;


  var jsonData = {
    message: msg
  }
  var options =
  {
    "method" : "post",
    "contentType" : "application/x-www-form-urlencoded",
    "payload" : jsonData,
    "headers": {"Authorization": "Bearer " + key}
  };

  var res = UrlFetchApp.fetch(url, options);
}
  }
