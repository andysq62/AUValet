Function Export-AUEnvironmentConfig
{
[CmdletBinding()]
param (
[parameter(Mandatory,Position=0)]
[String]$Path,
[parameter(Mandatory=$False,Position=1)]
[String]$AdminAccount = 'ColleagueAdministrator'
)
$Cred = Get-AUCredential -AdminAccount $AdminAccount
Get-AUEnvironmentConfig | Export-CliXML $Path
}