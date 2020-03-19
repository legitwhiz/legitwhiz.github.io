#-----------------------------------------------------
# 前日のイベントログをテキストファイルに出力する
# 出力ファイル:"D:\logs\application_091128.txt"
#           "D:\logs\security_091128.txt"
#           "D:\logs\system_091128.txt""
#-----------------------------------------------------

set-PSDebug -strict

# イベントログ取得開始時刻の設定
$start_time_today = [system.datetime]
$start_time_yesterday= [system.datetime]
$start_time_today = get-date -hour "0" -minute "0" -second "0"
$start_time_yesterday = $start_time_today.AddDays(-1)   # 前日の0時0分0秒

# イベントログ取得終了時刻の設定
$end_time_today = [system.datetime]
$end_time_yesterday= [system.datetime]
$end_time_today = get-date -hour "23" -minute "59" -second "59"
$end_time_yesterday = $end_time_today.AddDays(-1)   # 前日の24時59分59秒

# 出力先フォルダを設定する
$dir = [string]
$dir = "D:\SakaTmp\logs"    

# system、application、securityのログを出力する
$type = [string]
$name = [string]
$fPath = [string]
$event = [system.diagnostics.eventLogEntry]
foreach ($type in "system","application","security"){
    # 出力先テキストファイルのパスを設定
    $name = $type + "_" + $start_time_yesterday.tostring("yyyyMMdd") + ".txt" # 出力ファイル名(system)
    $fPath = $dir + "\" + $name
    
    # ログ取得
    $event = get-EventLog -logname $type -after $start_time_yesterday -before $end_time_yesterday 
    
    # テキストファイルに出力
    $event > $fPath
}

Write-host "完了しました"

trap{
    Write-host "エラーが発生しました"
    break
}