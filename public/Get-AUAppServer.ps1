Function Get-AUAppServer
{
[CmdletBinding()]
param (
[parameter(Mandatory,Position=0)]
   [String]$Environment
)
   (Import-AUEnvironmentConfig | Where { $_.Environment -eq $Environment }).AppHost | Write-Output
}
