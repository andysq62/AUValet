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
.PARAMETER Environment
The Colleague environment
.EXAMPLE
Start-AUListener -Name prod_APP_LISTENER,prod_DB_LISTENER -Environment prod

Starts the main applications and db listeners for the 
prod environment.
.NOTES
The listeners must be set to auto start for this function to work.
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
[parameter(Mandatory,Position=1)]
[String[]]$Name
)
$Cred = Get-AUCredential -AdminAccount 'ColleagueAdministrator'
$Listeners = Get-AUListener -Name $Name -Environment $Environment

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

