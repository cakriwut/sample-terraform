$package = 'ssms'
# Requires $env:AdminUser $env:AdminPassword
Set-ExecutionPolicy Bypass -Scope Process -Force
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

Enable-WSManCredSSP -Role Server -Force
Enable-WSManCredSSP -Role Client -DelegateComputer * -Force
New-Item -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredentialsDelegation -Name AllowFreshCredentialsWhenNTLMOnly -Force
New-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredentialsDelegation\AllowFreshCredentialsWhenNTLMOnly -Name 1 -Value * -PropertyType String

$user = "$($env:computername)\$($env:AdminUser)"
$securePassword = ConvertTo-SecureString $env:AdminPassword  -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential $user,$securePassword
Invoke-Command -Authentication CredSSP -ScriptBlock {choco install sql-server-express -y} -ComputerName $env:computername -Credential $credential
foreach ($pkg in $package) {
    Invoke-Command -ScriptBlock { choco install $args[0] -y } -ArgumentList $pkg 
}