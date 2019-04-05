Function Stop-AUUnidata
{
<#
.SYNOPSIS
Stops Unidata.
.DESCRIPTION
Stop-AUUnidata stops UniData in the given environment on the appropriate
applications server.
.PARAMETER Environment
The Colleague environment
.PARAMETER Force
Force shutdown of UniData
.PARAMETER User
Optional user under which to run the process.  (Make this a credential)
.EXAMPLE
Stop-AUUnidata -Environment prod

Stops UniData in the 'prod' environment.
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
   [String]$Environment,
[String]$AdminAccount = 'ColleagueAdministrator',
[Switch]$Force
)
$Cred = get-AUCredential -AdminAccount $AdminAccount
$AppServer = Get-AUAppServer -Environment $Environment


   "$Environment Now stopping UniData" | Write-AULog

   $Result = Invoke-Command -ComputerName $AppServer -Credential $Cred {

   $StopUdt = Join-Path $env:UDTBIN 'stopudt.exe'
   $StopUd = Join-Path $env:UDTBIN 'stopud.exe'
   Set-Location $env:UDTBIN


<#
   Get-Process -Name udt | ForEach {
      & $StopUdt $_.id
   }
#>


   if(Test-Path -Path $StopUd)
   {
      if($Using:Force.IsPresent) {
         "Stopping UniData with force"
         & "$stopud -f"
      } else {
         "Now stopping UniData"
         & $stopud
      }
   } else {
         "$environment Path not found when stopping UniData"
      }
}
"$Environment $Result" Write-AULog

}     # End Function
