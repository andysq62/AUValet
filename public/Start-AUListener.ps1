Function Start-AUListener
{
<#
.SYNOPSIS
Starts specific listeners for a Colleague environment.
.DESCRIPTION
Start-AUListener starts specifically named listeners for 
a given Colleague environment.
.PARAMETER Name
A list of listener name(s) to start.
.PARAMETER Port
A list of listener Port(s) to start.
.PARAMETER Environment
The Colleague environment
.EXAMPLE
Start-AUListener -Name prod_APP_LISTENER,prod_DB_LISTENER -Environment prod

Starts the main applications and db listeners for the 
prod environment.
.Example
Start-AUListener -Environment clean -Port 7500

Starts the port in the clean environment running on port 7500
.NOTES
The listeners must be set to auto start for this function to work.
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
   if($L.Status -match 'Running') {
      "$Environment $($L.Listener) is already Running" | Write-AULog
   } else {
      "$Environment Starting $($L.Listener) on $($L.Host)" | Write-AULog
      Invoke-Command -ComputerName $L.Host -Credential $Cred {
         Start-Service -Name $Using:L.Listener
      }
   }
} # End loop through listeners

}

