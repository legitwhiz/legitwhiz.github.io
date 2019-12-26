// Post処理するやつ
//https://synapse-diary.com/?p=5379

function doPost(e) {
  var json = JSON.parse(e.postData.contents);
  if (json.events[0].message.type = 'image') {
    var blob = get_line_content(json.events[0].message.id);
    // 全部画像として扱っちゃう
    var text = ocr(blob);
    reply(json, text);
  }
}

// 画像とか取得するやつ
function get_line_content(message_id) {
  var headers = {
    'Authorization': 'Bearer ' + getProp('CHANNEL_ACCESS_TOKEN')
  };
  var options = {
    'method'  : 'GET',
    'headers': headers
  };
  var url = 'https://api.line.me/v2/bot/message/' + message_id + '/content';
  var blob = UrlFetchApp.fetch(url, options).getBlob();
  return blob;
}

// OCRするやつ
function ocr(imgBlob) {
  var resource = {
    title: imgBlob.getName(),
    mimeType: imgBlob.getContentType()
  };
  var options = {
    ocr: true
  };
  try {
    var imgFile = Drive.Files.insert(resource, imgBlob, options);
    var doc = DocumentApp.openById(imgFile.id);
    var text = doc.getBody().getText().replace("\n", "");
    var res = Drive.Files.remove(imgFile.id);
  } catch(e) {
    spreadsheetLog('err in ocr::ocr: '+e);
    return 'err';
  }
  return text;
}
