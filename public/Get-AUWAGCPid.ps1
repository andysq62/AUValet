Function Get-AUWAGCPid
{
<#
.SYNOPSIS
Retrieves the WAGC process ID.
.DESCRIPTION
Get-AUWAGCPid retrieves the process ID of WAGC in the given environment.
.PARAMETER Environment
the Colleague environment
.PARAMETER User
The user under whose credentials the query will run.
.EXAMPLE
Get-AUWAGCPid -Environment test

Retrieves the WAGC Pid for the test environment.
#>
[CmdletBinding()]
param (
   [parameter(Mandatory,Position=0)]
   [String]$Environment,
[String]$AdminAccount = 'ColleagueAdministrator'
)
$Cred = Get-AUCredential -AdminAccount $AdminAccount
$PrimaryNode = Get-AUSQLNode -Environment $Environment
$WAGCPidFieldNo = 12
$Q = "SELECT * FROM dbo.PARMS WHERE PARMS_ID = 'GC.STATUS~UT'"

$GCStatus = Invoke-Command -ComputerName $PrimaryNode -Credential $Cred {
Invoke-SQLCmd -Database $Using:Environment -Query $Using:Q
}
$WAGCPid = ($GCStatus.PARMS_RCD.Split([Char]254))[$WAGCPidFieldNo].Split(' ')[0]

$WAGCPid | Write-Output
}

