Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
choco feature enable -n allowGlobalConfirmation
choco install microsoft-edge-insider
choco install googlechrome
choco install firefox
choco install docker-cli

Get-ScheduledTask -TaskName ServerManager | Disable-ScheduledTask -Verbose