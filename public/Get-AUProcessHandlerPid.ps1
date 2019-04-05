Function Get-AUProcessHandlerPid
{
<#
.SYNOPSIS
Retrieves the process handler process ID.
.DESCRIPTION
Get-AUProcessHandlerPid retrieves the process ID of Process Handler in the given environment.
.PARAMETER Environment
the Colleague environment
.PARAMETER User
The user under whose credentials the query will run.
.EXAMPLE
Get-AUProcessHandlerPid -Environment test

Retrieves the Process Handler Pid for the test environment.
#>
[CmdletBinding()]
param (
   [parameter(Mandatory,Position=0)]
   [String]$Environment,
[String]$AdminAccount = 'ColleagueAdministrator'
)
$Cred = Get-AUCredential -AdminAccount $AdminAccount
$Apphome = Get-AUApphome -Environment $Environment
$ProcessHandlerPid = $Null

$ProcessHandlerPid = Invoke-Command -ComputerName (Get-AUAppServer -Environment $Environment) -Credential $Cred -ErrorAction SilentlyContinue {
$PhantActiveQueues = $Using:Apphome + "\PHANTOM.CONTROL\PHANT.ACTIVE.QUEUES"
if(Test-Path -Path $PhantActiveQueues)
{
(Get-Content $PhantActiveQueues)[10].split(' ')[0]
} else {
$Null
}
}
$ProcessHandlerPid | Write-Output
}

