# All items in C:\Temp older than three days are deleted.
# This runs daily.

Get-ChildItem C:\Temp | ForEach-Object { 
    if ( $_.LastWriteTime -le (Get-Date).AddDays(-3) )
    { 
        Remove-Item $_.FullName -Recurse
    }
}