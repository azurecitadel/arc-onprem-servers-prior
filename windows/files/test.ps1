# PowerShell test file

# Set-ExecutionPolicy Bypass -Scope Process -Force

Write-Host "Configure Windows Azure VM to allow Azure Arc agent to be deployed."

# Set-Service WindowsAzureGuestAgent -StartupType Disabled -Verbose
# Stop-Service WindowsAzureGuestAgent -Force -Verbose


$Message = "Hello World"
$Today = (Get-Date).DateTime

"$Today : $Message" | Out-File C:\terraform\test.txt

# This last command will restart the adapter so you may get the following error:
# Error: error executing "C:/Temp/terraform_1069060186.cmd": unknown error
# Post "http://51.140.8.245:5985/wsman": read tcp 192.168.214.189:39940->51.140.8.245:5985: read: connection reset by peer
# New-NetFirewallRule -Name BlockAzureIMDS -DisplayName "Block access to Azure IMDS" -Enabled True -Profile Any -Direction Outbound -Action Block -RemoteAddress 169.254.169.254