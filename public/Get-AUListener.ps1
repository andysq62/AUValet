Function Get-AUListener
{
<#
.SYNOPSIS
Get-AUListener retrieves information on specific Colleague 
listeners.
.DESCRIPTION
Get-AUListener retrieves information on specific Colleague 
listeners into an array of objects.  
Information includes server, environment, listener name, 
install path, status, and auto maintenance mode.  
.PARAMETER Name
the name of the listener(s) to be retrieved.

.PARAMETER Environment
The Colleague environment for which listener info is gathered.  
.PARAMETER UseReportingNode
This flag will query the reporting node for the data instead of the primary node.  
.EXAMPLE
$Listeners = @('test_APP_LISTENER','test_SS_LISTENER','test_WA_LISTENER')
Get-AUListener -Name $Listeners -Environment test | Format-List

Retrieves and displays information for all applications 
listeners in the test environment.
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
[parameter(Mandatory,Position=1)]
[String[]]$Name,
[Switch]$UseReportingNode
)
$Cred = Get-AUCredential -AdminAccount 'ColleagueAdministrator'
$q = 'SELECT DMILISTENERS_ID, DMI_HOST, DMI_INSTALL_PATH FROM dbo.DMILISTENERS'
$ListenerList = @()

if($UseReportingNode.IsPresent)
{
   $Node = Get-AUSQLNode -Environment $Environment -UseReportingNode
} else {
   $Node = Get-AUSQLNode -Environment $Environment
}

$ListenerList = Invoke-Command -ComputerName $Node -Credential $Cred {
   Invoke-SQLCmd -database $Using:Environment -Query $Using:q
} | Where { $Name -Contains $_.DMILISTENERS_ID }

$Listeners = @()

Foreach ($L in $ListenerList) {

Write-Verbose "L.DMI_HOST: $($L.DMI_HOST)"

$ListenerState = Invoke-Command -ComputerName $L.DMI_HOST -Credential $Cred {
   $Status = (Get-Service -Name $Using:L.DMILISTENERS_ID).Status

   $KeyStore = (Get-IniContent (Join-Path $Using:L.DMI_INSTALL_PATH 'dmi.ini'))['No-Section']['ListenerKeyStore']
if($KeyStore) {
   $AutoFlag = $True
} else {
   $AutoFlag = $False
}

   $obj = New-Object -TypeName PSObject -Property @{
Status = $Status
AutoFlag = $AutoFlag
}

$Obj | Write-Output
}     # End Invoke Command


   $Listeners += New-Object -TypeName PSObject -Property @{
      Listener = $L.DMILISTENERS_ID
      Host = $L.DMI_HOST
      InstallPath = $L.DMI_INSTALL_PATH
      Status = $ListenerState.Status
      AutoFlag = $ListenerState.AutoFlag
   }
} # End loop through listeners

$Listeners | Write-Output
}

