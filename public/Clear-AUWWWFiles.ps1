Function Clear-AUWWWFiles
{
<#
.SYNOPSIS
Clears WWW files in a Colleague environment.
.DESCRIPTION
Clear-AUWWWFiles runs two paragraphs in UniData--COUNT.WWW and CLEAR.WWW.
.PARAMETER Environment
The Colleague environment
.EXAMPLE
Clear-AUWWWFiles -Environment prod

Runs two UniData paragraphs to clear the WWW files in the prod environment.
#>
[CmdletBinding()]
param (
   [parameter(Mandatory,Position=0)]
[ValidateScript({
   If(!(Test-AUEnvironment -Environment $_))
   {
      Throw "One or more environments is invalid...try again."
   } else {
      $True
   } 
})]
   [String]$Environment
)
$Cred = Get-AUCredential -AdminAccount 'ColleagueAdministrator'
$PrimaryNode = Get-AUSQLNode -Environment $Environment
$Apphome = Get-AUApphome -Environment $Environment

"$Environment Clearing WWW Files" | Write-AUlog

Invoke-Command -ComputerName (Get-AUAppServer -Environment $Environment) -Credential $Cred {
   Set-Location $Using:Apphome
   $Udt = Join-Path $env:UDTBIN 'udt'
   Foreach ($PA in ('COUNT.WWW','CLEAR.WWW')) {
#      & $udt $PA
 start-process udt -WorkingDirectory $Using:Apphome -argumentList $PA -Passthru -WindowStyle Hidden
   }
}
}

