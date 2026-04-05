# TermChat Windows PowerShell version

$RepoDir = "$HOME\TermChatRepo"
$LogFile = "$RepoDir\messages.log"

if (!(Test-Path $RepoDir)) { New-Item -ItemType Directory -Path $RepoDir }

cd $RepoDir

if (!(Test-Path ".git")) {
    $RepoURL = Read-Host "Enter your GitHub repo HTTPS URL"
    git clone $RepoURL .
}

while ($true) {
    $Message = Read-Host "You"
    $Timestamp = Get-Date -UFormat %s
    Add-Content -Path $LogFile -Value "$Timestamp|$Message"
    git add messages.log
    git commit -m "new message"
    git push origin main
    
    Clear-Host
    Write-Output "----- Chat -----"
    git pull origin main
    Get-Content messages.log
    Write-Output "----------------"
}
