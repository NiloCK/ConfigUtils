
# installing chocolatey
iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))


choco install powershell -pre -y

choco install nodejs.install -y
choco install javaruntime -y

choco install git.install -y
choco install poshgit -y
choco install atom -y

