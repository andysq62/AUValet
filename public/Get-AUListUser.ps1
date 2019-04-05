Function Get-AUListUser
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

   $ListUser = Invoke-Command -ComputerName (Get-AUAppServer -Environment $Environment) -Credential $Cred {
      listuser
   }

$Start = 6
$End = $Listuser.Count - 2
$Procs = @()
$ListUser[$Start..$End] | Foreach {
$UdtProc = ($_.Trim()) -Split '\s+', 8
$Obj = New-Object -TypeName PSObject -Property @{
UdtNo = $UdtProc[0]
UserNum = $UdtProc[1]
UID = $UdtProc[2]
UserName = $UdtProc[3]
UserType = $UdtProc[4]
TTY = $UdtProc[5]
IPAddress = $UdtProc[6]
DateTime = [DateTime]$UdtProc[7]
}
$Procs += $Obj
}
Write-Output $Procs
}
