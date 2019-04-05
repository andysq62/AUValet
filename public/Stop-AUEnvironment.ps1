Function Stop-AUEnvironment
{
<#
.SYNOPSIS
Shuts down all listeners for a Colleague environment.
.DESCRIPTION
Shuts down all listeners for a given Colleague environment 
with the exception of the Datatel daemons.  Includes both 
database and applications listeners.
.PARAMETER Environment
The Colleague environment
.PARAMETER IncludeDaemon
this switch will also shut down the Datatel daemons for the 
environment.  Not yet implemented.
.EXAMPLE
Stop-AUEnvironment -Environment prod

Shuts down all listeners except the daemons for the prod 
environment.
#>
[CmdletBinding()]
param(
[parameter(mandatory,Position=0)]
[ValidateScript({
   If(!(Test-AUEnvironment -Environment $_))
   {
      Throw "One or more environments is invalid...try again."
   } else {
      $True
   } 
})]
[String]$Environment,
[Switch]$IncludeDaemon
)
$Cred = Get-AUCredential -AdminAccount 'ColleagueAdministrator'

foreach ($L in (Get-AUEnvironment -Environment $Environment)) {
   if($L.Status -match 'Stopped') {
      "$Environment $($L.Listener) is already stopped" | Write-AULog
   } elseif(!($L.Listener -match 'DB_LISTENER')) {
      "$Environment Stopping $($L.Listener) on $($L.Host)" | Write-AULog
      Invoke-Command -ComputerName $L.Host -Credential $Cred {
          Stop-Service -Name $Using:L.Listener
      }
   }
} # End loop through listeners
# Now stop the DB listener
Stop-AUListener -Environment $Environment -Name "${Environment}_DB_LISTENER"

if($IncludeDaemon.IsPresent) {
   Write-Verbose 'Now Stopping Datatel Daemons--Not yet implemented'
}
}

