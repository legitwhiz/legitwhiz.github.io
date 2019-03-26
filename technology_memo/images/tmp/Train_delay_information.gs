//Train_delay_information.gs
function getDelayInfo() {
  //電車遅延情報をJSON形式で取得
  var json = JSON.parse(UrlFetchApp.fetch("https://rti-giken.jp/fhc/api/train_tetsudo/delay.json").getContentText());
  //路線名を指定
  var name="湘南新宿ライン";
  //運営会社名を指定
  var company="JR東日本";
  var message="";
 
  for each(var obj in json){
    //指定した路線名と運営会社名に一致する遅延情報を取得
    if(obj.name === name && obj.company === company){
 
      message = company + name + "が遅延しています";
    }
  }
  
  if(!message){ 
    message = "現在遅延情報はありません";
  } else { 
 
  //遅延情報をLINE Notifyに送信
  sendHttpPost(message);
  }
}

function sendHttpPost(message){
  //アクセストークンを設定
  var token = ["fkRf9pBD9UOvmuBloFxwuWeCrGROMbqV094RI8Blyiu"];
  //LINE Notifyに送るリクエストを設定
  var options =
   {
     "method"  : "post",
     "payload" : "message=" + message,
     "headers" : {"Authorization" : "Bearer "+ token}

   };

   //リクエスト送信
   UrlFetchApp.fetch("https://notify-api.line.me/api/notify",options);
}
