#-----------------------------------------------------
# 前日のイベントログ(event-id:2)をテキストファイルに出力する
# 出力ファイル:"D:\SakaTmp\document\_091128.txt"
#-----------------------------------------------------

set-PSDebug -strict

# 出力先フォルダを設定する
$dir = [string]
$dir = "D:\SakaTmp\logs\"
$hostname = "localhost"

##################
# 前回営業日判定 #
##################

# イベントログ取得開始時刻の設定
$start_time_today = get-date -hour "0" -minute "0" -second "0"
$end_time_today = get-date -hour "23" -minute "59" -second "59"
$start_time_yesterday = $start_time_today.AddDays(-1) #-1の日付を入れる
$end_time_yesterday  = $end_time_today.AddDays(-1) #-1の日付を入れる

$HOLIDAYFILE = Get-Content ${dir}holidaylist.txt #祝日(厳密には会社の土日以外の定休日)をリスト化したファイル
$HOLIDATE_S = ($start_time_yesterday).ToString("yyyyMMdd")
$HOLIDATE_E = ($end_time_yesterday).ToString("yyyyMMdd")
$WEEKDATE_S = ($start_time_yesterday).DayOfWeek
$WEEKDATE_E = ($end_time_yesterday).DayOfWeek

###次回営業日になるまで永久ループ

#祝日判定

do {
    do {
        #土日判定
        if ( $WEEKDATE_S -eq "Saturday" ) {
            $start_time_yesterday = $start_time_yesterday.AddDays(-1) #土曜日に-1日して金曜日に合わせる
            $end_time_yesterday = $end_time_yesterday.AddDays(-1) #土曜日に-1日して金曜日に合わせる
            $HOLIDATE_S = ($start_time_yesterday).ToString("yyyyMMdd")
            $HOLIDATE_E = ($end_time_yesterday).ToString("yyyyMMdd")
            $WEEKDATE_S = ($start_time_yesterday).DayOfWeek
            $WEEKDATE_E = ($end_time_yesterday).DayOfWeek
     } elseif ( $WEEKDATE_S -eq "Sunday" ) {
            $start_time_yesterday = $start_time_yesterday.AddDays(-1) #日曜日に-2日して金曜日に合わせる
            $end_time_yesterday = $end_time_yesterday.AddDays(-1) #日曜日に-2日して金曜日に合わせる
            $HOLIDATE_S = ($start_time_yesterday).ToString("yyyyMMdd")
            $HOLIDATE_E = ($end_time_yesterday).ToString("yyyyMMdd")
            $WEEKDATE_S = ($start_time_yesterday).DayOfWeek
            $WEEKDATE_E = ($end_time_yesterday).DayOfWeek
     }
    $HOLIDAYFILE | 
        foreach -Process { if ( $HOLIDATE_S -eq ( $_ )) {
        $start_time_yesterday = $start_time_yesterday.AddDays(-1) #祝日に-1日して翌日で再度ループ判定
        $end_time_yesterday = $end_time_yesterday.AddDays(-1) #祝日に-1日して翌日で再度ループ判定
        $HOLIDATE_S = ($start_time_yesterday).ToString("yyyyMMdd")
        $HOLIDATE_E = ($end_time_yesterday).ToString("yyyyMMdd")
        $WEEKDATE_S = ($start_time_yesterday).DayOfWeek
        $WEEKDATE_E = ($end_time_yesterday).DayOfWeek
        }
    }
    } while ( $WEEKDATE_S -eq "Saturday")
} while ( $WEEKDATE_S -eq "Sunday")


#-----------------------------------------------------
echo $start_time_yesterday
echo $end_time_yesterday

$filter = @{}
$filter.Add("LogName", "SYSTEM")
$filter.Add("ID", 2)                             # EventID
$filter.Add("Level", 3)                          #level Warning
$filter.Add("StartTime", $start_time_yesterday)  # 前日の0時0分0秒
$filter.Add("EndTime", $end_time_yesterday)      # 前日の24時59分59秒

# systemのログを出力する
$type = [string]
$name = [string]
$fPath = [string]
$event = [system.diagnostics.eventLogEntry]

foreach ($type in "system"){
    # 出力先テキストファイルのパスを設定
    $name = "eventlog_bluetooth" + ".txt" # 出力ファイル名
    $fPath = $dir + "\" + $name
    $start_day = $start_time_yesterday.tostring("yyyyMMdd")
    
    # ログ取得
   #$event = get-EventLog -logname $type -after $start_time_yesterday -before $end_time_yesterday -FilterXPath "*[System[Provider[@Name='EventLog'] and (EventID='2'')]]"
   #$event = Get-WinEvent -logname $type -FilterXPath "*[System[Provider[@Name='EventLog'] and (EventID='2')]]" -after $start_time_yesterday -before $end_time_yesterday
    $event_Count = (Get-WinEvent -ComputerName $hostname -ErrorAction SilentlyContinue -FilterHashtable $filter | Measure-Object).Count
    # テキストファイルに出力
    $start_day + "," + $event_Count >> $fPath
}

Write-host "完了しました"

trap{
    Write-host "エラーが発生しました"
    break
}
