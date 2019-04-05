Function Get-AUSQLNode
{
<#
.SYNOPSIS
Gets the reporting or primary node on SQL server for a Colleague environment.
#>
[CmdletBinding()]
param(
[parameter(Mandatory,Position=0)]
[String]$Environment,
[Switch]$UseReportingNode
)
(Import-AUEnvironmentConfig | Where { $_.Environment -eq $Environment }).DBHost | Write-Output
}

