###########################################################################
#
#  システム名      ：  
#  サブシステム名  ：  
#  スクリプト名    ：  UIAutomationLV2CSV_export.ps1
#  機能名          ：  LV2CSVをGUI操作しCSVにexport
#  機能概要　      ：  ListView to CSV(LV2CSV.exe）のGUIからタイプ数カウンターをCSVにexportする。
#  CALLED BY       ：  
#  CALL TO         ：  NONE
#  ARGUMENT        ：  1.無し
#                      2.無し  
#  RETURNS         ：  0      正常 
#                      0以外  異常 
#-------------------------------------------------------------------------
#  作成元          ：  新規
#  作成日　        ： 2018/09/10    作成者　：　D.SAKAMOTO(legit whiz)
#  修正履歴　      ：
#
###########################################################################
$exePath = "D:\SakaTmp\tool\lvcs2.25.05_x64\LV2CSV.EXE"
$LogDir = "D:\SakaTmp\logs\type_count\"

# [ Import-Module ]コマンドレットでUIAutomation.dllをインポートする。
Import-Module D:\SakaTmp\tool\UiAutomation\UIAutomation.dll

# [ Start-Process ]コマンドレットでLV2CSV.exを起動する。
$process = Start-Process $exePath -PassThru | Get-UiaWindow;

$start_time_today = [system.datetime]
$start_time_today = get-date -hour "0" -minute "0" -second "0"
$targetFile = $start_time_today.tostring("yyyyMMdd") + "_type.csv"

$target_full_path = $LogDir + $targetFile;

# $target_full_path があれば削除
if(Test-Path $target_full_path){
    Remove-Item $target_full_path -Force
}

# ListView to CSV画面のtype数カウンターを選択
$process.Keyboard.KeyDown([WindowsInput.Native.VirtualKeyCode]::MENU) | Out-Null; # Alt キーを押す
$process.Keyboard.KeyPress([WindowsInput.Native.VirtualKeyCode]::VK_C) | Out-Null; # C キーを押す
$process.Keyboard.KeyUp([WindowsInput.Native.VirtualKeyCode]::MENU) | Out-Null; # Alt キーを放す
$process.Keyboard.KeyPress([WindowsInput.Native.VirtualKeyCode]::DOWN) | Out-Null; # ↓ キーを押す
# 0.1 秒停止
Start-Sleep -m 500
$process.Keyboard.KeyPress([WindowsInput.Native.VirtualKeyCode]::UP) | Out-Null; # ↑ キーを押す
# 0.1 秒停止
Start-Sleep -m 500

# Alt + v → Enter の順でキーを押すと，[名前を付けて保存]画面が出る
$process.Keyboard.KeyPress([WindowsInput.Native.VirtualKeyCode]::MENU) | Out-Null; # Alt キーを押す
$process.Keyboard.KeyPress([WindowsInput.Native.VirtualKeyCode]::VK_V) | Out-Null; # v キーを押す
$process.Keyboard.KeyPress([WindowsInput.Native.VirtualKeyCode]::RETURN) | Out-Null; # Enter キーを押す
Start-Sleep -m 500

# リスト中にあるアイテムを選択して開く
$openWnd = Get-UiaWindow -Name '名前を指定して保存';
$selectItem = $openWnd | Get-UiaEdit -Name 'ファイル名:';
$selectItem.Value = $LogDir + $targetFile;
$selectItem.Keyboard.KeyPress([WindowsInput.Native.VirtualKeyCode]::RETURN) | Out-Null;

# 0.7 秒停止
Start-Sleep -m 700

# [OK]ボタンを押す
$window = Get-UiaWindow -Name 'ListView to CSV'
$window | Get-UiaButton -Name 'OK' | Invoke-UiaButtonClick | Out-Null

# 0.3 秒停止
Start-Sleep -m 500

# 閉じる
$window.Keyboard.KeyDown([WindowsInput.Native.VirtualKeyCode]::MENU) | Out-Null; # Alt キーを押す
$window.Keyboard.KeyPress([WindowsInput.Native.VirtualKeyCode]::F4) | Out-Null; # F4 キーを押す
$window.Keyboard.KeyUp([WindowsInput.Native.VirtualKeyCode]::MENU) | Out-Null; # Alt キーを押す

# 0.3 秒停止
Start-Sleep -m 500

if(!(Test-Path $target_full_path)){
        echo File Create Eroor
        exit 1
}

# shutdown -h now
Stop-Computer -Force
