Get-WinEvent -logname System -FilterXPath "*[System[Provider[@Name='EventLog'] and (EventID='6005' or EventID='6006')]]" -maxevents 30

