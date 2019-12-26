
###########################################################################
#
#  �V�X�e����      �F  �����F�؃V�X�e�� 
#  �T�u�V�X�e����  �F  �Ǘ��pWindowsServer
#  �X�N���v�g��    �F  eventlog_backup_logrotate.ps1
#  �@�\��          �F  �C�x���g���O�o�b�N�A�b�v�����[�e�[�g�X�N���v�g
#  �@�\�T�v�@      �F  �O�����̃C�x���g���O���e�L�X�g�t�@�C���ɏo�͂��Â����O���폜����B
#  CALLED BY       �F  
#  CALL TO         �F  NONE
#  ARGUMENT        �F  1.����
#                      2.����  
#  RETURNS         �F  0      ���� 
#                      0�ȊO  �ُ� 
#-------------------------------------------------------------------------
#  �쐬��          �F  �V�K
#  �쐬���@        �F 2018/09/04    �쐬�ҁ@�F�@D.SAKAMOTO(MT)
#  �C�������@      �F
#
###########################################################################

set-PSDebug -strict

# �C�x���g���O�擾�J�n�����̐ݒ�
$start_time_today = [system.datetime]
$start_time_yesterday= [system.datetime]
$start_time_today = get-date -hour "0" -minute "0" -second "0"
$start_time_yesterday = $start_time_today.AddDays(-1)   # �O����0��0��0�b

# �C�x���g���O�擾�I�������̐ݒ�
$end_time_today = [system.datetime]
$end_time_yesterday= [system.datetime]
$end_time_today = get-date -hour "23" -minute "59" -second "59"
$end_time_yesterday = $end_time_today.AddDays(-1)   # �O����24��59��59�b

# �o�͐�t�H���_��ݒ肷��
$EventLog_Dir = [string]
$Script_Dir = [string]
$Home_Dir = [string]
#$Home_Dir = "C:\Users\Administrator"
$Home_Dir = "D:\SakaTmp\logs"
$EventLog_Dir = $Home_Dir + "\Backup_EventLog"
$ScriptLog_Dir = $Home_Dir + "\Log"

# �o�b�N�A�b�v�ۑ����Ԑݒ�
[string] $saving_days = 365

$Eventlog_type = [string]
$Backup_Fname = [string]
$Full_Backup_Fname = [string]
$ScriptLog = [string]
$ScriptFName = [string]

# Script Log File Name�ݒ�
$ScriptFName = Split-Path -Leaf $PSCommandPath
[string] $ScriptLog = $ScriptLog_Dir + "\" + $ScriptFName + "_" + $start_time_today.tostring("yyyyMMdd") + ".log"

# Script Messages
[string] $START_MSG = (Get-Date).ToString("yyyy/MM/dd HH:mm:ss") + $ScriptFName + "���J�n���܂����B"
[string] $END_MSG = (Get-Date).ToString("yyyy/MM/dd HH:mm:ss") + $ScriptFName + "���I�����܂����B"
[string] $Success_MSG01 = (Get-Date).ToString("yyyy/MM/dd HH:mm:ss") + " (" + $EventLog_Dir + ")" + "�o�b�N�A�b�v����C�x���g���O���i�[����f�B���N�g���쐬�ɐ������܂����B"
[string] $Success_MSG02 = (Get-Date).ToString("yyyy/MM/dd HH:mm:ss") + " (" + $ScriptLog_Dir + ")" + "�X�N���v�g���O���i�[����f�B���N�g���쐬�ɐ������܂����B"
[string] $Success_MSG03 = (Get-Date).ToString("yyyy/MM/dd HH:mm:ss") + " ���O�擾�R�}���h���s���������܂����B"
[string] $Success_MSG04 = (Get-Date).ToString("yyyy/MM/dd HH:mm:ss") + " " + $saving_days + "�����Â��C�x���g���O�t�@�C���폜���������܂����B"

[string] $Error_MSG01 = (Get-Date).ToString("yyyy/MM/dd HH:mm:ss") + " (" + $EventLog_Dir + ")" + "�o�b�N�A�b�v����C�x���g���O���i�[����f�B���N�g���쐬�Ɏ��s���܂����B"
[string] $Error_MSG02 = (Get-Date).ToString("yyyy/MM/dd HH:mm:ss") + " (" + $ScriptLog_Dir + ")" + "�X�N���v�g���O���i�[����f�B���N�g���쐬�Ɏ��s���܂����B"
[string] $Error_MSG03 = (Get-Date).ToString("yyyy/MM/dd HH:mm:ss") + " ���O�擾�R�}���h���s�����s���܂����B"
[string] $Error_MSG04 = (Get-Date).ToString("yyyy/MM/dd HH:mm:ss") + " " + $saving_days + "�����Â��C�x���g���O�t�@�C���폜�����s���܂����B"

echo $START_MSG >> $ScriptLog

$event_BKcommand = [system.diagnostics.eventLogEntry]

# $ScriptLog_Dir ���Ȃ���΍쐬
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

# $EventLog_Dir ���Ȃ���΍쐬
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

# system�Aapplication�Asecurity�̃��O���o�͂���
foreach ($Eventlog_type in "system","application","security"){

    # �o�͐�e�L�X�g�t�@�C���̃t���p�X��ݒ�
    $Backup_Fname = $Eventlog_type + "_" + $start_time_yesterday.tostring("yyyyMMdd") + ".txt" # �o�̓t�@�C����
    $Full_Backup_Fname = $EventLog_Dir + "\" + $Backup_Fname

    # ���O�擾�R�}���h�ݒ�
    $event_BKcommand = get-EventLog -logname $Eventlog_type -after $start_time_yesterday -before $end_time_yesterday 

    # ���O�擾�R�}���h���s���A�e�L�X�g�t�@�C���ɏo��
    $event_BKcommand > $Full_Backup_Fname

    if ($? -eq $true) {
        echo "$Success_MSG03 ($Eventlog_type)" >> $ScriptLog
    }
    else {
        echo "$Error_MSG03 ($Eventlog_type)" >> $ScriptLog
        exit 1
    }
}


### �o�b�N�A�b�v���O�t�@�C�����[�e�[�V�����֐�
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
