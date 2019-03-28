
###########################################################################
#
#  システム名      ：  統合認証システム 
#  サブシステム名  ：  管理用WindowsServer
#  スクリプト名    ：  eventlog_backup_logrotate.ps1
#  機能名          ：  イベントログバックアップ＆ローテートスクリプト
#  機能概要　      ：  前日分のイベントログをテキストファイルに出力し古いログを削除する。
#  CALLED BY       ：  
#  CALL TO         ：  NONE
#  ARGUMENT        ：  1.無し
#                      2.無し  
#  RETURNS         ：  0      正常 
#                      0以外  異常 
#-------------------------------------------------------------------------
#  作成元          ：  新規
#  作成日　        ： 2018/09/04    作成者　：　D.SAKAMOTO(MT)
#  修正履歴　      ：
#
###########################################################################

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
$EventLog_Dir = [string]
$Script_Dir = [string]
$Home_Dir = [string]
#$Home_Dir = "C:\Users\Administrator"
$Home_Dir = "D:\SakaTmp\logs"
$EventLog_Dir = $Home_Dir + "\Backup_EventLog"
$ScriptLog_Dir = $Home_Dir + "\Log"

# バックアップ保存期間設定
[string] $saving_days = 365

$Eventlog_type = [string]
$Backup_Fname = [string]
$Full_Backup_Fname = [string]
$ScriptLog = [string]
$ScriptFName = [string]

# Script Log File Name設定
$ScriptFName = Split-Path -Leaf $PSCommandPath
[string] $ScriptLog = $ScriptLog_Dir + "\" + $ScriptFName + "_" + $start_time_today.tostring("yyyyMMdd") + ".log"

# Script Messages
[string] $START_MSG = (Get-Date).ToString("yyyy/MM/dd HH:mm:ss") + $ScriptFName + "が開始しました。"
[string] $END_MSG = (Get-Date).ToString("yyyy/MM/dd HH:mm:ss") + $ScriptFName + "が終了しました。"
[string] $Success_MSG01 = (Get-Date).ToString("yyyy/MM/dd HH:mm:ss") + " (" + $EventLog_Dir + ")" + "バックアップするイベントログを格納するディレクトリ作成に成功しました。"
[string] $Success_MSG02 = (Get-Date).ToString("yyyy/MM/dd HH:mm:ss") + " (" + $ScriptLog_Dir + ")" + "スクリプトログを格納するディレクトリ作成に成功しました。"
[string] $Success_MSG03 = (Get-Date).ToString("yyyy/MM/dd HH:mm:ss") + " ログ取得コマンド実行が成功しました。"
[string] $Success_MSG04 = (Get-Date).ToString("yyyy/MM/dd HH:mm:ss") + " " + $saving_days + "日より古いイベントログファイル削除が成功しました。"

[string] $Error_MSG01 = (Get-Date).ToString("yyyy/MM/dd HH:mm:ss") + " (" + $EventLog_Dir + ")" + "バックアップするイベントログを格納するディレクトリ作成に失敗しました。"
[string] $Error_MSG02 = (Get-Date).ToString("yyyy/MM/dd HH:mm:ss") + " (" + $ScriptLog_Dir + ")" + "スクリプトログを格納するディレクトリ作成に失敗しました。"
[string] $Error_MSG03 = (Get-Date).ToString("yyyy/MM/dd HH:mm:ss") + " ログ取得コマンド実行が失敗しました。"
[string] $Error_MSG04 = (Get-Date).ToString("yyyy/MM/dd HH:mm:ss") + " " + $saving_days + "日より古いイベントログファイル削除が失敗しました。"

echo $START_MSG >> $ScriptLog

$event_BKcommand = [system.diagnostics.eventLogEntry]

# $ScriptLog_Dir がなければ作成
if(!(Test-Path $ScriptLog_Dir)){
    New-Item $ScriptLog_Dir -ItemType Directory
    if ($? -eq $true) {
        echo $Success_MSG02 >> $ScriptLog
    }
    else {
        echo $Error_MSG02 >> $ScriptLog
        exit 1
    }
}

# $EventLog_Dir がなければ作成
if(!(Test-Path $EventLog_Dir)){
    New-Item $EventLog_Dir -ItemType Directory
    if ($? -eq $true) {
        echo $Success_MSG01 >> $ScriptLog
    }
    else {
        echo $Error_MSG01 >> $ScriptLog
        exit 1
    }
} 

# system、application、securityのログを出力する
foreach ($Eventlog_type in "system","application","security"){

    # 出力先テキストファイルのフルパスを設定
    $Backup_Fname = $Eventlog_type + "_" + $start_time_yesterday.tostring("yyyyMMdd") + ".txt" # 出力ファイル名
    $Full_Backup_Fname = $EventLog_Dir + "\" + $Backup_Fname

    # ログ取得コマンド設定
    $event_BKcommand = get-EventLog -logname $Eventlog_type -after $start_time_yesterday -before $end_time_yesterday 

    # ログ取得コマンド実行し、テキストファイルに出力
    $event_BKcommand > $Full_Backup_Fname

    if ($? -eq $true) {
        echo "$Success_MSG03 ($Eventlog_type)" >> $ScriptLog
    }
    else {
        echo "$Error_MSG03 ($Eventlog_type)" >> $ScriptLog
        exit 1
    }
}


### バックアップログファイルローテーション関数
$today = Get-Date
$logs = Get-ChildItem $EventLog_Dir
foreach ($TargetFileName in $logs) {
    if ($TargetFileName.lastWriteTime -lt $today.AddDays(-$saving_days)) {
        Remove-Item $TargetFileName.FullName -Force
            if ($? -eq $true) {
               echo $Success_MSG04 >> $ScriptLog
            }
            else {
                echo $Error_MSG04 >> $ScriptLog
                exit 1
            }
    }
}

echo $END_MSG >> $ScriptLog
