# All items in C:\Temp older than three days are deleted.
# This runs daily.

Get-ChildItem C:\Temp | ForEach-Object {
    if ( $_.LastWriteTime -le (Get-Date).AddDays(-3) )
    {
        Remove-Item $_.FullName -Recurse
    }
}

"This directory is cleaned automatically, nightly. Files older than three days will be deleted. DO NOT STORE THINGS HERE!" > C:\Temp\DoNotLeaveThingsHere.txt
