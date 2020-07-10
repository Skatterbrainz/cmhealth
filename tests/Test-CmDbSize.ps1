function Test-CmDbSize {
	[CmdletBinding()]
	param (
		[parameter(Mandatory)][ValidateNotNullOrEmpty()][hashtable] $ScriptParams
	)
	Write-Verbose "test: database file size utilization"
	$maxUtilization = 95
	try {
		$devices = Invoke-DbaQuery -SqlInstance $ScriptParams.SqlInstance -Database $ScriptParams.Database -Query "select distinct ResourceID,Name0 from v_R_System"
		Write-Verbose "calculating expected space requirements"
		$devSizeMB = (($devices.Count * 5MB) + 5GB) / 1MB
		Write-Verbose "expected space: $devSizeMB MB"
		$dbSizeMB = (Get-DbaDatabase -SqlInstance $ScriptParams.SqlInstance -Database $ScriptParams.Database).SizeMB
		Write-Verbose "actual space: $dbSizeMB MB"
		$pct = ([math]::Round($devSizeMB / $dbSizeMB, 1)) * 100
		Write-Verbose "actual utilization: $pct`%"
		if ($pct -gt $maxUtilization) {$result = 'FAIL'} else {$result = 'PASS'}
	}
	catch {
		$result = 'ERROR'
		Write-Error $_.Exception.Message
	}
	finally {
		$result
	}
}
