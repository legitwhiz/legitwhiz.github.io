#-----------------------------------------------------
# �O���̃C�x���g���O(event-id:2)���e�L�X�g�t�@�C���ɏo�͂���
# �o�̓t�@�C��:"D:\SakaTmp\document\_091128.txt"
#-----------------------------------------------------

set-PSDebug -strict

# �o�͐�t�H���_��ݒ肷��
$dir = [string]
$dir = "D:\SakaTmp\logs\"
$hostname = "localhost"

##################
# �O��c�Ɠ����� #
##################

# �C�x���g���O�擾�J�n�����̐ݒ�
$start_time_today = get-date -hour "0" -minute "0" -second "0"
$end_time_today = get-date -hour "23" -minute "59" -second "59"
$start_time_yesterday = $start_time_today.AddDays(-1) #-1�̓��t������
$end_time_yesterday  = $end_time_today.AddDays(-1) #-1�̓��t������

$HOLIDAYFILE = Get-Content ${dir}holidaylist.txt #�j��(�����ɂ͉�Ђ̓y���ȊO�̒�x��)�����X�g�������t�@�C��
$HOLIDATE_S = ($start_time_yesterday).ToString("yyyyMMdd")
$HOLIDATE_E = ($end_time_yesterday).ToString("yyyyMMdd")
$WEEKDATE_S = ($start_time_yesterday).DayOfWeek
$WEEKDATE_E = ($end_time_yesterday).DayOfWeek

###����c�Ɠ��ɂȂ�܂ŉi�v���[�v

#�j������

do {
    do {
        #�y������
        if ( $WEEKDATE_S -eq "Saturday" ) {
            $start_time_yesterday = $start_time_yesterday.AddDays(-1) #�y�j����-1�����ċ��j���ɍ��킹��
            $end_time_yesterday = $end_time_yesterday.AddDays(-1) #�y�j����-1�����ċ��j���ɍ��킹��
            $HOLIDATE_S = ($start_time_yesterday).ToString("yyyyMMdd")
            $HOLIDATE_E = ($end_time_yesterday).ToString("yyyyMMdd")
            $WEEKDATE_S = ($start_time_yesterday).DayOfWeek
            $WEEKDATE_E = ($end_time_yesterday).DayOfWeek
     } elseif ( $WEEKDATE_S -eq "Sunday" ) {
            $start_time_yesterday = $start_time_yesterday.AddDays(-1) #���j����-2�����ċ��j���ɍ��킹��
            $end_time_yesterday = $end_time_yesterday.AddDays(-1) #���j����-2�����ċ��j���ɍ��킹��
            $HOLIDATE_S = ($start_time_yesterday).ToString("yyyyMMdd")
            $HOLIDATE_E = ($end_time_yesterday).ToString("yyyyMMdd")
            $WEEKDATE_S = ($start_time_yesterday).DayOfWeek
            $WEEKDATE_E = ($end_time_yesterday).DayOfWeek
     }
    $HOLIDAYFILE | 
        foreach -Process { if ( $HOLIDATE_S -eq ( $_ )) {
        $start_time_yesterday = $start_time_yesterday.AddDays(-1) #�j����-1�����ė����ōēx���[�v����
        $end_time_yesterday = $end_time_yesterday.AddDays(-1) #�j����-1�����ė����ōēx���[�v����
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
$filter.Add("StartTime", $start_time_yesterday)  # �O����0��0��0�b
$filter.Add("EndTime", $end_time_yesterday)      # �O����24��59��59�b

# system�̃��O���o�͂���
$type = [string]
$name = [string]
$fPath = [string]
$event = [system.diagnostics.eventLogEntry]

foreach ($type in "system"){
    # �o�͐�e�L�X�g�t�@�C���̃p�X��ݒ�
    $name = "eventlog_bluetooth" + ".txt" # �o�̓t�@�C����
    $fPath = $dir + "\" + $name
    $start_day = $start_time_yesterday.tostring("yyyyMMdd")
    
    # ���O�擾
   #$event = get-EventLog -logname $type -after $start_time_yesterday -before $end_time_yesterday -FilterXPath "*[System[Provider[@Name='EventLog'] and (EventID='2'')]]"
   #$event = Get-WinEvent -logname $type -FilterXPath "*[System[Provider[@Name='EventLog'] and (EventID='2')]]" -after $start_time_yesterday -before $end_time_yesterday
    $event_Count = (Get-WinEvent -ComputerName $hostname -ErrorAction SilentlyContinue -FilterHashtable $filter | Measure-Object).Count
    # �e�L�X�g�t�@�C���ɏo��
    $start_day + "," + $event_Count >> $fPath
}

Write-host "�������܂���"

trap{
    Write-host "�G���[���������܂���"
    break
}
