Function Stop-AUListener
{
<#
.SYNOPSIS
Shuts down specific listeners for a Colleague environment.
.DESCRIPTION
Stop-AUListener Shuts down specifically named listeners by name or port for 
a given Colleague environment.
.PARAMETER Name
A list of listener name(s) to shut down.
.PARAMETER Port
A list of listener port(s) to shut down.
.PARAMETER Environment
The Colleague environment
.EXAMPLE
Stop-AUListener -Name prod_APP_LISTENER,prod_DB_LISTENER -Environment prod

Shuts down the main applications and db listeners for the 
prod environment.
.Example
Stop-AUListener -Environment clean -Port 7500

Stops the listener on port 7500 in the clean environment
#>
[CmdletBinding()]
param(
[parameter(mandatory,Position=0)]
[Parameter(ParameterSetName='ByName')]
[Parameter(ParameterSetName='ByPort')]
[ValidateScript({
   If(!(Test-AUEnvironment -Environment $_))
   {
      Throw "One or more environments is invalid...try again."
   } else {
      $True
   } 
})]
[String]$Environment,
[parameter(Mandatory,ParameterSetName='ByName')]
[String[]]$Name,
[parameter(Mandatory,ParameterSetName='ByPort')]
[String[]]$Port
)
$Cred = Get-AUCredential -AdminAccount 'ColleagueAdministrator'

If($PSCmdlet.ParameterSetName -eq 'ByName')
{
   $Listeners = Get-AUListener -Environment $Environment -Name $Name
} elseif($PSCmdlet.ParameterSetName -eq 'ByPort')  {
   $Listeners = Get-AUListener -Environment $Environment -Port $Port
}

# Foreach ($L in $Listeners) { Write-Verbose $L.listener }

foreach ($L in $Listeners) {
   if($L.Status -match 'Stopped') {
      Write-Verbose "$($L.Listener) is already stopped"
   } else {
      "$Environment Stopping $($L.Listener) on $($L.Host)" | Write-AULog
      Invoke-Command -ComputerName $L.Host -Credential $Cred {
         Stop-Service -Name $Using:L.Listener
      }
   }
} # End loop through listeners

}

