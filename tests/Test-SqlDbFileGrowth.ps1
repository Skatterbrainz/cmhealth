<#
.EXAMPLE
Test-SqlDbFileGrowth.ps1
#>
[CmdletBinding()]
param (
	[parameter(Mandatory)][ValidateNotNullOrEmpty()][hashtable] $ScriptParams
)
Write-Verbose "test: sql db file autogrowth"
Write-Verbose "database: $($ScriptParams.Database)"
if ($null -eq )
try {
	$dbfiles = Get-DbaDbFile -SqlInstance $ScriptParams.SqlInstance -Database $ScriptParams.Database
	switch ($ScriptParams.FileType) {
		'Database' {
			$files = $dbfiles | Where-Object {$_.TypeDescription -eq 'Rows'}
			$test1 = $files | Where-Object {$_.GrowthType -eq 'Percent' -and $_.Growth -ge 10}
			$test2 = $files | Where-Object {$_.GrowthType -eq '' -and $_.Growth -ge 256}
			if ($test1.Count -gt 1 -and 
		}
		'Log' {}
	} # switch
}
catch {}
finally {
	$result
}