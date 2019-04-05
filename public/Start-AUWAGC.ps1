Function Start-AUWAGC
{
<#
.SYNOPSIS
Startss WAGC
.DESCRIPTION
Start-AUWAGC starts WAGC in the given environment
.PARAMETER Environment
The Colleague environment
.PARAMETER User
Optional user under which to run the process.  (Make this a credential)
.EXAMPLE
Start-AUWAGC -Environment prod

Starts WAGC in the prod environment
#>
[CmdletBinding()]
param (
   [parameter(Mandatory,Position=0)]
   [String]$Environment,
[String]$AdminAccount = 'ColleagueAdministrator'
)
$Cred = get-AUCredential -AdminAccount $AdminAccount
$Apphome = Get-AUApphome -Environment $Environment

   "$Environment Now starting WAGC" | Write-AULog
$Result =    Invoke-Command -ComputerName (Get-AUAppServer -Environment $Environment) -Credential $Cred {
#       Set-Location $Using:Apphome
#       $Udt = Join-Path $env:UDTBIN 'udt'
#       & $udt "$($Using:Name)"
      start-process udt -WorkingDirectory $Using:Apphome -argumentList "PHANTOM","DMI_GC_DRIVER","0~360~0~ellucian" -Passthru -WindowStyle Hidden
   }
$Result | Write-Output
}
