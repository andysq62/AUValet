Function Stop-AUProcessHandler
{
<#
.SYNOPSIS
Stops the Process Handler for a Colleague environment.
.DESCRIPTION
Stops the Process Handler for a given Colleague environment.
.PARAMETER Environment
The Colleague environment
.EXAMPLE
Stop-AUProcessHandler -Environment prod

Stops the Process Handler in the prod 
environment.
#>
[CmdletBinding()]
param (
[parameter(Mandatory,Position=0)]
[String]$Environment
)
$ProcessHandlerCred = Get-AUCredential -AdminAccount 'ProcessHandler'

$ProcessHandler = Get-AUProcessHandler -Environment $Environment
If($ProcessHandler)
{
   $PHId = $ProcessHandler.Id
Write-Verbose "Now stopping process $phid"
   $StoppedProcess = Invoke-Command -ComputerName (Get-AUAppServer -Environment $Environment) -Credential $ProcessHandlerCred {
      Stop-Process -id $Using:PHId -Passthru
   }
}
   $StoppedProcess | Write-Output
}