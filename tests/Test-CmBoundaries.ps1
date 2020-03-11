[CmdletBinding()]
param (
	[parameter(Mandatory)][ValidateNotNullOrEmpty()][hashtable] $ScriptParams
)
Write-Verbose "test: cm boundaries"
try {
	$query = "select * from vSMS_Boundary"
	$boundaries = Invoke-DbaQuery -SqlInstance $ScriptParams.SqlInstance -Database $ScriptParams.Database -Query $query
	$dupes = $boundaries | Group-Object -Property BoundaryType,Value | Select-Object Count,Name
	$orphaned = $boundaries | Where-Object {$_.GroupCount -eq 0}
	switch ($ScriptParams.Test) {
		'DuplicateBoundaries' {
			if (($dupes | Where-Object {$_.Count -gt 1}) -gt 0) {
				$result = 'FAIL'
			}
			else {
				$result = 'PASS'
			}
		}
		'Orphaned' {
			if ($orphaned.Count -gt 1) {
				$result = 'FAIL'
			}
			else {
				$result = 'PASS'
			}
		}
	}
}
catch {
	Write-Error $_.Exception.Message 
	$result = 'ERROR'
}
finally {
	$result
}