Function Remove-AUOldFiles
{
[CmdletBinding()]
param(
   [parameter(Mandatory,Position=0)]
[ValidateScript({
   If(!(Test-AUEnvironment -Environment $_))
   {
      Throw "One or more environments is invalid...try again."
   } else {
      $True
   } 
})]
   [String[]]$Environment
)
$Cred = Get-AUCredential -AdminAccount 'ColleagueAdministrator'

Foreach ($E in $Environment) {

$Apphome = Get-AUApphome -Environment $E
Invoke-Command -ComputerName (Get-AUAppServer -Environment $E) -Credential $Cred {
$_PH_ = Join-Path $Using:Apphome '_PH_'
$_HOLD_ = Join-Path $Using:Apphome '_HOLD_'
$SAVEDLISTS = Join-Path $Using:Apphome 'SAVEDLISTS'
$FILETRANSFERS = Join-Path $Using:Apphome 'FILETRANSFERS'

If(Test-Path $_PH_)
{
   $Files = Get-ChildItem $_PH_ | 
     Where { $_.Lastwritetime -lt (Get-Date).AddDays(-7) }
   $Files | Sort Lastwritetime | Out-File D:\Scripts\Logs\RemovedPHFiles.log
   $Files | Remove-Item
}


If(Test-Path $_HOLD_)
{
   $Files = Get-ChildItem $_HOLD_ -Exclude *PRIVATE*,*KEEP* | 
     Where { $_.Lastwritetime -lt (Get-Date).AddDays(-10) }
   $Files | Sort Lastwritetime | Out-File D:\Scripts\Logs\RemovedHOLDFiles.log
   $Files | Remove-Item
}


If(Test-Path $SAVEDLISTS)
{
   $Files = Get-ChildItem $SAVEDLISTS -Exclude *KEEP* | 
     Where { $_.Lastwritetime -lt (Get-Date).AddDays(-30) }
   $Files | Sort Lastwritetime | Out-File D:\Scripts\Logs\RemovedSLFiles.log
   $Files | Remove-Item
}

$UIExportDir = Join-Path $Using:Apphome 'UI.EXPORT.DIR'
If(Test-Path -Path $UIExportDir) {
   Get-ChildItem $UIExportDir -Exclude ExcelExport.xlsx | Remove-Item
}

$CommonAppPath = Join-Path $FileTransfers 'A26.AD.COMMON.APP'
If(Test-Path $CommonAppPath)
{
   $Files = Get-ChildItem $CommonAppPath | 
     Where { $_.Lastwritetime -lt (Get-Date).AddDays(-30) }
   $Files | Out-File D:\Scripts\Logs\RemovedCommonAppFiles.log
   $Files | Remove-Item
}
}     #End Invoke Command
}     #End loop through environments
}