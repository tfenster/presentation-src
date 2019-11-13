Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
choco feature enable -n allowGlobalConfirmation
choco install git
choco install vscode
choco install microsoft-edge-insider
choco install googlechrome
choco install firefox

cd c:\
wget https://github.com/tfenster/presentation-src/archive/techdays-19.zip -OutFile sources.zip
Expand-Archive .\sources.zip
rm .\sources.zip

Get-ScheduledTask -TaskName ServerManager | Disable-ScheduledTask -Verbose