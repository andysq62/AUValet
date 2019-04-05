Function Invoke-AUUnidataCommand
{
<#
.SYNOPSIS
Runs a Unidata paragraph.
.DESCRIPTION
Invoke-AUUnidataParagraph runs a VOC item / paragraph in the given environment
.PARAMETER Environment
The Colleague environment
.PARAMETER Name
The name of the VOC / paragraph to run.
.PARAMETER User
Optional user under which to run the process.  (Make this a credential)
.EXAMPLE
Invoke-AUUnidataParagraph -Environment prod -Name 'CLEAR.WWW'

Runs the CLEAR.WWW paragraph in a Unidata session in the prod environment.
#>
[CmdletBinding()]
param (
   [parameter(Mandatory,Position=0)]
   [String]$Environment,
   [parameter(Mandatory,Position=1)]
   [String]$Name,
[String]$AdminAccount = 'ColleagueAdministrator'
)
$Cred = get-AUCredential -AdminAccount $AdminAccount
$Apphome = Get-AUApphome -Environment $Environment

   "$Environment Now running UniData paragraph $Name" | Write-AULog
   Invoke-Command -ComputerName (Get-AUAppServer -Environment $Environment) -Credential $Cred {
      Set-Location $Using:Apphome
      $Udt = Join-Path $env:UDTBIN 'udt'
      & $udt "$($Using:Name)"
# start-process udt -WorkingDirectory $Using:Apphome -argumentList $Using:Name -Passthru -WindowStyle Hidden
   }
}
