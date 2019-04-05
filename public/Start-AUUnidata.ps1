Function Start-AUUnidata
{
<#
.SYNOPSIS
Starts Unidata.
.DESCRIPTION
Start-AUUnidata starts UniData in the given environment on the appropriate
applications server.
.PARAMETER Environment
The Colleague environment
.PARAMETER User
Optional user under which to run the process.  (Make this a credential)
.EXAMPLE
Start-AUUnidata -Environment prod

Starts UniData in the 'prod' environment.
#>
[CmdletBinding()]
param (
   [parameter(Mandatory,Position=0)]
   [String]$Environment,
[String]$AdminAccount = 'ColleagueAdministrator'
)
$Cred = get-AUCredential -AdminAccount $AdminAccount

   $Result = Invoke-Command -ComputerName (Get-AUAppServer -Environment $Environment) -Credential $Cred {
      $StartUd = Join-Path $env:UDTBIN 'startud.exe'
      if(Test-Path -Path $StartUd)
      {
         Set-Location $env:UDTBIN
"Now starting UniData"
         & "$startud -s"
      } else {
         "$environment Path not found when starting UniData"
      }
   }
"$Environment $Result" | Write-AULog
}
