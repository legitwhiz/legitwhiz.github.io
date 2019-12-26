$NEXTDATE = (Get-Date).AddDays(-1) 
$HOLIDAYFILE = Get-Content D:\SakaTmp\logs\holidaylist.txt #祝日(厳密には会社の土日以外の定休日)をリスト化したファイル
$HOLIDATE = ($NEXTDATE).ToString("yyyyMMdd")
$WEEKDATE = ($NEXTDATE).DayOfWeek

echo $HOLIDATE

$HOLIDAYFILE | 
        foreach -Process { if ( $HOLIDATE -eq ( $_ )) {
            $NEXTDATE = $NEXTDATE.AddDays(-1) 
            $HOLIDATE = ($NEXTDATE).ToString("yyyyMMdd")
            $WEEKDATE = ($NEXTDATE).DayOfWeek
            echo $NEXTDATE 3
            }


do {
do {

if ( $WEEKDATE -eq "Saturday" ) {
$NEXTDATE = $NEXTDATE.AddDays(-1) 
$HOLIDATE = ($NEXTDATE).ToString("yyyyMMdd")
$WEEKDATE = ($NEXTDATE).DayOfWeek
echo $NEXTDATE 1

} elseif ( $WEEKDATE -eq "Sunday" ) {
$NEXTDATE = $NEXTDATE.AddDays(-2) 

$HOLIDATE = ($NEXTDATE).ToString("yyyyMMdd")
$WEEKDATE = ($NEXTDATE).DayOfWeek
echo $NEXTDATE 2
}



} while ( $WEEKDATE -eq "Sunday")
} while ( $WEEKDATE -eq "Saturday")

}



echo $NEXTDATE.ToString("yyyyMMdd")
