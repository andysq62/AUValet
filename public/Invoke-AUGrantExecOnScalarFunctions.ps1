Function Invoke-AUGrantExecOnScalarFunctions
{
<#
.SYNOPSIS
Invoke-AUGrantExecOnScalarFunctions Runs the sp_grant_exec_on_scalar_functions 
stored procedure in the provided environments.  It outputs 
a text file with the generated SQL statements, and then 
runs those statements in the listed environments.
.DESCRIPTION
Invoke-AUGrantExecOnScalarFunctions selects the 
corresponding primary node for listed environments and runs 
the sp_grant_exec_on_scalar_functions stored procedure, 
generates a flat file, and runs the generated SQL.

.PARAMETER Environment
The environment/database in which the stored procedure and generated 
SQL will be run.
.EXAMPLE
Get-AUGrantExecOnScalarFunctions -Environment test

Runs the stored procedure and generated SQL in the primary node of the test environment.
.EXAMPLE
Invoke-AUGrantExecOnScalarFunctions -Environment prod,test -Verbose

Runs the stored procedure and generated SQL on the primary 
nodes for the production and test environments, and 
displays verbose output.
#>
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
$Query = 'exec sp_grant_exec_on_scalar_functions'
$Cred = Get-AUCredential -AdminAccount 'ColleagueAdministrator'

Foreach ($E in $Environment) {
   $PrimaryNode = Get-AUSQLNode -Environment $E
   Write-Verbose "Running grant exec on scalar functions on $E $PrimaryNode"

   $Result = Invoke-Command -Computername $PrimaryNode -Credential $Cred {
      $SQLFile = 'D:\Scripts\GrantExecOnScalarFunctions.sql'
      $Database = $Using:E

      $SQLOutput = Invoke-SQLCmd -Database $Database -Query $Using:Query
      $SQLOutput.Script | out-File $SQLFile

      If(Test-Path -Path $SQLFile) {
         Invoke-SQLCmd -Database $Database -InputFile $SQLFile
      }
   }  # End Invoke Command
}  # End loop through environments.
'Grant Exec On Scalar Functions Complete' | Send-AUMail -To (Get-AUEmail -EMail 'DBA') -Subject 'Grant Exec On Scalar Functions is complete in development, test and prod'

}

