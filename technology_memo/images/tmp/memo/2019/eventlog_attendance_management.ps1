#-----------------------------------------------------
# 前日のイベントログ(event-id:6005,6006)を30日分テキストファイルに出力する
# 出力ファイル:"D:\SakaTmp\eventlog_attendance_management.log"
#-----------------------------------------------------

set-PSDebug -strict

# 出力先フォルダを設定する
$dir = [string]
$dir = "D:\SakaTmp\logs\"    
$hostname = "localhost"
$eventID = 6005, 6006
#-----------------------------------------------------

$filter = @{}
$filter.Add("LogName", "SYSTEM")
$filter.Add("ID", $eventID)                             # EventID

# systemのログを出力する
$type = [string]
$name = [string]
$fPath = [string]
$event = [system.diagnostics.eventLogEntry]

foreach ($type in "system"){
    # 出力先テキストファイルのパスを設定
    $name = "eventlog_attendance_management" + ".log" # 出力ファイル名
    $fPath = $dir + "\" + $name
    # ログ取得
    $event_log = Get-WinEvent -ComputerName $hostname -ErrorAction SilentlyContinue -FilterHashtable $filter -maxevents 60
    # テキストファイルに出力
    $event_log > $fPath
}

Write-host "完了しました"

trap{
    Write-host "エラーが発生しました"
    break
}

