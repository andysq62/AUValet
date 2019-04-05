Function Get-AUEDXSubscriber
{
<#
.SYNOPSIS
Retrieves information for EDX subscribers.

.DESCRIPTION
Get-AUEDXSubscriber takes the name of an environment as 
input and outputs an array of objects for each subscriber.  
Properties include Environment, Subscriber, Status and 
Description.  

.PARAMETER Environment
The Colleague environment

.PARAMETER Valid
Limits the subscribers to those currently monitored in a 
given environment.

.EXAMPLE
Get-AUEDXSubscriber -Environment prod | Format-Table

Displays environment, status and description data for all 
EDX subscribers in the prod environment.

.EXAMPLE
Get-AUEDXSubscriber -Environment prod -Valid | Format-Table

Displays information for just the subscribers currently being monitored in the environment.
.NOTES
This function uses a helper function, 
GET-AUEDXValidSubscriber, to determine currenltly monitored 
subscribers in an environment.
#>
[CmdletBinding()]
param (
[parameter(mandatory,Position=0)]
[String]$Environment,
[Switch]$Valid
)
$Cred = Get-AUCredential -AdminAccount 'ColleagueAdministrator'
$Node = Get-AUSQLNode -Environment $Environment
$Query = 'SELECT EDX_SUBSCRIBERS_ID, EDXSUB_DESCRIPTION, EDXSUB_STATUS FROM dbo.EDX_SUBSCRIBERS'
$ValidEDX = Get-AUEDXValidSubscriber -environment $Environment

Write-Verbose "Now retrieving from $Environment on $Node"

$EDXSubscribers = Invoke-Command -ComputerName $Node -Credential $Cred {
   Invoke-SQLCmd -Database $Using:environment -Query $Using:Query }

$EDXOut = @()
ForEach ($EDXSub in $EDXSubscribers) {
   if($Valid.IsPresent) {
      if($ValidEDX -Contains $EDXSub.EDX_SUBSCRIBERS_ID) {
         Write-Verbose 'Now getting EDX Subscribers to check status'
         $EDXOut += $EDXSub
      }
   } else {
      $EDXOut += $EDXSub
   }
}  # End for loop through all subscribers

$Subscribers = @()
Foreach ($ES in $EDXOut) {
   $Obj = New-Object -TypeName PSObject -Property @{
   Environment = $Environment
   SUBSCRIBER = $ES.EDX_SUBSCRIBERS_ID
   DESCRIPTION = $ES.EDXSUB_DESCRIPTION
   STATUS = $ES.EDXSUB_STATUS
   }
   $Subscribers += $Obj
}
Write-Output $Subscribers
}

