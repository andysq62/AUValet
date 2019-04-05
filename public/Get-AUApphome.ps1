Function Get-AUApphome
{
[CmdletBinding()]
param (
[parameter(Mandatory,Position=0)]
[String]$Environment
)
(Import-AUEnvironmentConfig | Where { $_.Environment -eq $Environment }).Apphome | Write-Output
}