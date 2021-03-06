
# installing chocolatey
iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))

# brings PS to version 4 (if at 2), and to version 5 (if at 4)
choco install powershell -pre -y

# runtimes
choco install nodejs.install -y
choco install javaruntime -y
choco install python -y

# version control utilities
choco install git.install -y
choco install poshgit -y
choco install winmerge -y
choco install sourcetree -y

New-Item \dev -ItemType dir

git clone https://www.github.com/NiloCK/ConfigUtils/ C:\dev\Configutils

choco install atom \y
