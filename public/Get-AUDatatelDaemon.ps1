Function Get-AUDatatelDaemon
{
<#
.SYNOPSIS
Retrieves status information for the datatel deamons associated with a given environment.

.DESCRIPTION
Get-AUDatatelDaemon takes an environment name as input and outputs an array of objects with properties of Name, Status and Host for the daemons.  Gets both database and applications daemons if on separate servers.

.PARAMETER Environment
The name of the Colleague environment

.EXAMPLE
Get-AUDatatelDaemon -Environment prod | Format-Table

Displays the daemon name, status and host for the prod environment.
#>
[CmdletBinding()]
param(
[parameter(Mandatory,Position=0)]
[String]$Environment
)
$Cred = Get-AUCredential -AdminAccount 'ColleagueAdministrator'
$Daemons = @()
Foreach ($ComputerName in (Get-AUDaemonHost -Environment $Environment)) {
   $Daemon = Invoke-Command -ComputerName $ComputerName -Credential $Cred {
      Get-Service DatatelDaemon
   } | Select Name, Status
   $Daemon | Add-Member Host $ComputerName
   $Daemons += $Daemon
}
Write-Output $Daemons
}

