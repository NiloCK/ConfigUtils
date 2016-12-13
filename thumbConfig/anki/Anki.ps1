# Starts anki w/ the local (portable) data folder
$ank = start-process -FilePath .\Anki\anki.exe -ArgumentList "-b .\ankidata" -Passthru

# check if this is 'one of my' computers
if (Test-Path C:\thumb\pf\anki)
{
    # if so...
    # wait until anki has closed
    wait-process -id $ank.id

    # then back up the data folder to the local drive
    Copy-Item -Recurse -Force .\ankidata C:\thumb\pf\Anki\
}