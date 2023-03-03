# install RODC on w2016-base

# configure networks
Disable-NetAdapter -Name 'LAN1' -Confirm:$false
Disable-NetAdapter -Name 'LAN3' -Confirm:$false
Disable-NetAdapter -Name 'LAN4' -Confirm:$false
New-NetIPAddress -InterfaceAlias "LAN2" -AddressFamily IPv4 -IPAddress "192.168.32.9" -PrefixLength 24 -DefaultGateway 192.168.32.5 -Confirm:$false
Set-DnsClientServerAddress -InterfaceAlias "LAN2" -ServerAddresses ("192.168.32.5") -Confirm:$false

# instal domain services
Install-WindowsFeature -Name 'AD-Domain-Services' -IncludeAllSubFeature -IncludeManagementTools -Confirm:$false 

# post deployment settings

$testingAdminPassword = ConvertTo-SecureString 'aaa' -AsPlainText -Force
$testingAdminCredential = New-Object System.Management.Automation.PSCredential ('administrator@testing.local', $testingAdminPassword)
$safeModeAdministratorPassword = ConvertTo-SecureString 'aaa' -AsPlainText -Force

Import-Module ADDSDeployment
Install-ADDSDomainController `
-AllowPasswordReplicationAccountName @("TESTING\Allowed RODC Password Replication Group") `
-NoGlobalCatalog:$false `
-Credential $testingAdminCredential `
-CriticalReplicationOnly:$false `
-SafeModeAdministratorPassword $safeModeAdministratorPassword `
-DatabasePath "C:\Windows\NTDS" `
-DelegatedAdministratorAccountName "TESTING\Simpsons" `
-DenyPasswordReplicationAccountName @("BUILTIN\Administrators", "BUILTIN\Server Operators", "BUILTIN\Backup Operators", "BUILTIN\Account Operators", "TESTING\Denied RODC Password Replication Group") `
-DomainName "testing.local" `
-InstallDns:$true `
-LogPath "C:\Windows\NTDS" `
-NoRebootOnCompletion:$false `
-ReadOnlyReplica:$true `
-ReplicationSourceDC "w2016-dc.testing.local" `
-SiteName "Default-First-Site-Name" `
-SysvolPath "C:\Windows\SYSVOL" `
-Force:$true
