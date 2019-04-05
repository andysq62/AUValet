Function Stop-AUEDX
{
<#
.SYNOPSIS
Stops EDX for a Colleague environment.
.DESCRIPTION
Stops EDX for a given Colleague environment.
.PARAMETER Environment
The Colleague environment
.EXAMPLE
Stop-AUEDX -Environment prod

Stops EDX in the prod 
environment.
#>
[CmdletBinding()]
param (
   [parameter(Mandatory,Position=0)]
   [String]$Environment
)
$EDXCred = Get-AUCredential -AdminAccount 'EDXManager'
$Cred = get-AUCredential -AdminAccount 'ColleagueAdministrator'
$PrimaryNode = Get-AUSQLNode -Environment $Environment
$q = "SELECT * FROM dbo.EDX_CONTROL WHERE EDX_CONTROL_ID = 'EDX'"
$Apphome = Get-AUApphome -Environment $Environment

$EdxControl = Invoke-Command -ComputerName $PrimaryNode -Credential $Cred {
   Invoke-SqlCmd -Database $Using:Environment -Query $Using:Q
}
"$Environment EDX Status Before Stop: $($EdxControl.EDX_CONTROL_TT_FLAG)" | Write-AULog

if($EdxControl.EDX_CONTROL_TT_FLAG -EQ 'H') {
   "$environment EDX is already stopped" | Write-AULog
} else {
   "$environment Now stopping EDX" | Write-AULog
   Invoke-Command -ComputerName (Get-AUAppServer -Environment $Environment) -Credential $EDXCred {
      Set-Location $Using:Apphome
      $udt = Join-Path $env:UDTBIN 'udt'
      & $udt 'EDX.PHANTOM.STOP'
   }
}
}

