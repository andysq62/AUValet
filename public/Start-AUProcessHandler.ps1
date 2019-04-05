Function Start-AUProcessHandler
{
<#
.SYNOPSIS
Starts the Process Handler for a Colleague environment.
.DESCRIPTION
Starts the Process Handler for a given Colleague environment.
.PARAMETER Environment
The Colleague environment
.EXAMPLE
Start-AUProcessHandler -Environment prod

Starts the Process Handler in the prod 
environment.
#>
[CmdletBinding()]
param (
[parameter(Mandatory,Position=0)]
[String]$Environment
)
$ProcessHandlerCred = Get-AUCredential -AdminAccount 'ProcessHandler'
$Cred = get-AUCredential -AdminAccount 'ColleagueAdministrator'
$PrimaryNode = Get-AUSQLNode -Environment $Environment
$Apphome = Get-AUApphome -Environment $Environment

If((Get-AUProcessHandlerPID -Environment $Environment)) {
   "$Environment Process handler is already running" | Write-AULog
   Return
}

"$environment Now starting process handler" | Write-AULog

   $Result = Invoke-Command -ComputerName (Get-AUAppServer -Environment $Environment) -Credential $ProcessHandlerCred {
      $udt = Join-Path $env:UDTBIN 'udt'
      Set-Location $Using:Apphome
      & $udt 'A26.START.PROCESS.HANDLER'
   }

$Result | Write-AULog
}

