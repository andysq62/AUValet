Function Get-AUWAGCProcess
{
<#
.SYNOPSIS
Retrieves the WAGC process.
.DESCRIPTION
Get-AUWAGCProcess retrieves the process object for WAGC in the given environment.
.PARAMETER Environment
the Colleague environment
.PARAMETER User
The user under whose credentials the query will run.
.EXAMPLE
Get-AUWAGCProcess -Environment test

Retrieves the WAGC Process object for the test environment.
#>
[CmdletBinding()]
param (
   [parameter(Mandatory,Position=0)]
   [String]$Environment,
[String]$AdminAccount = 'ColleagueAdministrator'
)
$Cred = Get-AUCredential -AdminAccount $AdminAccount
$AppServer = Get-AUAppServer -Environment $Environment
$WAGCPid = Get-AUWAGCPid -Environment $Environment

$WAGCService = Invoke-Command -ComputerName $AppServer -Credential $Cred {
   Get-Process -id $Using:WAGCPid -IncludeUserName -ErrorAction SilentlyContinue
}
$WAGCService | Write-Output
}

