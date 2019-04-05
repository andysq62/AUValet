Function Start-AUEDX
{
<#
.SYNOPSIS
Starts EDX for a Colleague environment.
.DESCRIPTION
Starts EDX for a given Colleague environment.
.PARAMETER Environment
The Colleague environment
.EXAMPLE
Start-AUEDX -Environment prod

Starts EDX in the prod 
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
 "$environment EDX status before start: $($EdxControl.EDX_CONTROL_TT_FLAG)" | Write-AULog

if($EdxControl.EDX_CONTROL_TT_FLAG -EQ 'S') {
   "$environment EDX is already running" | Write-AUlog
} else {
   "$environment Now starting EDX" | Write-AULog
   Invoke-Command -ComputerName (Get-AUAppServer -Environment $Environment) -Credential $EDXCred {
      $udt = Join-Path $env:UDTBIN 'udt'
      Set-Location $Using:Apphome
      & $udt 'EDX.PHANTOM.START'
   }
}
}

