Function Stop-AUWAGC
{
<#
.SYNOPSIS
Stops the WAGC process.
.DESCRIPTION
Stop-AUWAGC stops the WAGC process in the given environment.
.PARAMETER Environment
the Colleague environment
.PARAMETER User
The user under whose credentials the function will run.
.EXAMPLE
Stop-AUWAGC -Environment test

Stops the WAGC Process in the test environment.
#>
[CmdletBinding()]
param (
   [parameter(Mandatory,Position=0)]
   [String]$Environment,
[String]$AdminAccount = 'ColleagueAdministrator'
)
$Cred = Get-AUCredential -AdminAccount $AdminAccount
$AppServer = Get-AUAppServer -Environment $Environment
$WAGCPid = Get-AUWAGCPid -environment $Environment
if($WAGCPid)
{
$WAGCService = Invoke-Command -ComputerName $AppServer -Credential $Cred {
   Stop-Process -id $Using:WAGCPid -PassThru -ErrorAction SilentlyContinue
}
$WAGCService | Write-Output
}
}

