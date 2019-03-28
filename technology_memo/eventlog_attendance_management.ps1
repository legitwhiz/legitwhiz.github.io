#-----------------------------------------------------
# �O���̃C�x���g���O(event-id:6005,6006)��30�����e�L�X�g�t�@�C���ɏo�͂���
# �o�̓t�@�C��:"D:\SakaTmp\eventlog_attendance_management.log"
#-----------------------------------------------------

set-PSDebug -strict

# �o�͐�t�H���_��ݒ肷��
$dir = [string]
$dir = "D:\SakaTmp\logs\"    
$hostname = "localhost"
$eventID = 6005, 6006
#-----------------------------------------------------

$filter = @{}
$filter.Add("LogName", "SYSTEM")
$filter.Add("ID", $eventID)                             # EventID

# system�̃��O���o�͂���
$type = [string]
$name = [string]
$fPath = [string]
$event = [system.diagnostics.eventLogEntry]

foreach ($type in "system"){
    # �o�͐�e�L�X�g�t�@�C���̃p�X��ݒ�
    $name = "eventlog_attendance_management" + ".log" # �o�̓t�@�C����
    $fPath = $dir + "\" + $name
    # ���O�擾
    $event_log = Get-WinEvent -ComputerName $hostname -ErrorAction SilentlyContinue -FilterHashtable $filter -maxevents 60
    # �e�L�X�g�t�@�C���ɏo��
    $event_log > $fPath
}

Write-host "�������܂���"

trap{
    Write-host "�G���[���������܂���"
    break
}

