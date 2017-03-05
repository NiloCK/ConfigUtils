
# Load posh-git example profile
# . 'C:\Users\Colin\Documents\WindowsPowerShell\Modules\posh-git\profile.example.ps1'

$driveLetter = Get-Location
$driveLetter = $driveLetter.Drive.Name

#@ thumbLoc
## Takes a relative path and replaces it with the absolute path of
## the current session, respecting the drive letter of the thumb drive 
function thumbLoc () {
    return (-join ($driveLetter, ":\", $args[0]))
}

$profile = thumbLoc('pf\Powershell\thumbProfile.ps1'); 


function Set-Thumb-Alias ($alias, $location) {
    $absLoc = thumbLoc($location)
    Set-Alias $alias $absLoc -Scope global
}
function Copy-ThumbItem ($src, $dest) {
    $absSrc = thumbLoc($src);
    $absDest = thumbLoc($dest);

    Copy-Item $absSrc $absDest;
}

Set-Thumb-Alias st          'pf\st\sublime_text.exe'
Set-Thumb-Alias node        'pf\nodejs\node.exe'
Set-Thumb-Alias npm         'pf\nodejs\npm'
Set-Thumb-Alias ink         'pf\inkscape\InkscapePortable.exe'
Set-Thumb-Alias git         'pf\PortableGit\bin\git.exe'
Set-Thumb-Alias anki        'pf\Anki\anki.bat'
Set-Thumb-Alias yt          'pf\ytdl\youtube-dl.exe'
Set-Thumb-Alias ahk         'ahk.exe'
Set-Thumb-Alias ahkCompile  'pf\AutoHotkey\Compiler\Ahk2Exe.exe'
Set-Thumb-Alias sqlb        'pf\sqliteBrowser\SQLiteDatabaseBrowserPortable.exe'

function code ($loc) {
    $dataDir = thumbLoc('dev\ConfigUtils\home\vscode')
    $dataDir = (-join ('--user-data-dir ', $dataDir)).ToString()

    Start-Process -FilePath (thumbLoc('pf\VSCode\Bin\Code.cmd')) -ArgumentList ($dataDir), ($loc) -WindowStyle Hidden
}

# function glass {& C:\tools\PSGlass\Release\Glass.exe -t:$args[0]}
# glass 180

function Thumb-PullRepos () {
    $location = Get-Location;

    Get-ChildItem "C:\thumbRepos" | ForEach-Object {
        Write-Host (-Join "Updating:", $_.Name) -BackgroundColor Blue -ForegroundColor "Red"
        Set-Location $_.FullName;
        git pull;
    }

    Set-Location $location;
}

function Thumb-DeployConfig () {
    # lost and found
    Copy-ThumbItem 'dev\ConfigUtils\thumbConfig\READ THIS IF YOU FOUND THIS USB DRIVE.txt' 'READ THIS IF YOU FOUND THIS USB DRIVE.txt'
    
    # shell config / launcher / alias file
    Copy-ThumbItem 'dev\ConfigUtils\thumbConfig\powershell\thumbProfile.ps1' 'pf\powershell\thumbProfile.ps1'
    Copy-ThumbItem 'dev\ConfigUtils\thumbConfig\powershell\ps.bat' 'ps.bat'
    Copy-ThumbItem 'dev\ConfigUtils\thumbConfig\powershell\thumpm-g.ps1' 'pf\powershell\thumpm-g.ps1'
    
    # anki launchers
    Copy-ThumbItem 'dev\ConfigUtils\thumbConfig\anki\anki.bat' 'pf\Anki\anki.bat'
    Copy-ThumbItem 'dev\ConfigUtils\thumbConfig\anki\anki - nops.bat' 'pf\Anki\anki - nops.bat'
    Copy-ThumbItem 'dev\ConfigUtils\thumbConfig\anki\Anki.ps1' 'pf\Anki\Anki.ps1'

    # compile ahk script
    ahkCompile /in (thumbLoc('dev\ConfigUtils\ahk.ahk')) /out (thumbLoc('ahk.exe'))

    # distribute vscode settings files (to thumb & local machine)
    # //todo

    # $psLoc = thumbLoc('pf\Powershell\powershell.exe')
    # $procStr = -join ($psLoc, " -File ", $profile)
    # # $procStr = $procStr.ToString()
    # Start-Process $procStr;
}

function Thumb-ClearTmp () {
    $date = Get-Date;
    $date = $date.AddDays(-3);

    Get-ChildItem (thumbLoc('tmp')) | ForEach-Object {
        if ($_.LastWriteTime -le $date){
            Remove-Item $_.FullName
        }
    }

    "Files older than 3 days will automatically be deleted from this directory." | Out-File (thumbLoc('tmp\readme'))
}
function Thumb-Set-NPM-G(){
    & thumbLoc('pf\powershell\thumpm-g.ps1')
}

function Thumpm-Install-g ($package){
    $initialLocation = Get-Location;

    # install the package in 'pf/node_modules'
    Set-Location thumbLoc("pf");
#    npm install $package;
    
    # write alias to thumpm-g.ps1
    Add-Content thumbLoc('dev\ConfigUtils\thumbConfig\powershell\thumbpm-g.ps1')
        -Join "`r`nSet-Thumb-Alias ", $package, (thumbLoc("pf\node_modules\package\bin\")), $package
    
    # deploy and run thumpm-g.ps1 to enable the new alias
    Thumb-DeployConfig;
    Thumb-Set-NPM-G;

    # reset original location
    Set-Location $initialLocation;
}

# enable global NPM packages
Thumb-Set-NPM-G;