function Test-CmDbSize {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Check CM Site DB Size",
		[parameter()][string] $TestGroup = "database",
		[parameter()][string] $Description = "Validate CM site database file size",
		[parameter()][hashtable] $ScriptParams,
		[parameter()][int] $maxUtilization = 0.95
	)
	try {
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat = "PASS"
		$msg = "Correct configuration"
		$query = "select distinct ResourceID,Name0 from v_R_System"
		$devices = Invoke-DbaQuery -SqlInstance $ScriptParams.SqlInstance -Database $ScriptParams.Database -Query $query
		Write-Verbose "calculating expected space requirements"
		$devSizeMB = (($devices.Count * 5MB) + 5GB) / 1MB
		$recSize = $devSizeMB * $maxUtilization
		Write-Verbose "expected space: $devSizeMB MB (at $($devices.Count) devices)"
		$dbSizeMB = (Get-DbaDatabase -SqlInstance $ScriptParams.SqlInstance -Database $ScriptParams.Database).SizeMB
		Write-Verbose "actual space: $dbSizeMB MB"
		$pct = [math]::Round(($devSizeMB / $dbSizeMB) * 100, 1)
		Write-Verbose "actual utilization: $pct`%"
		if ($pct -gt $recSize) {
			$stat = 'FAIL'
			$msg = "Current DB size is $dbSizeMB MB ($pct percent of recommended). Recommended: $recSize MB"
		}
	}
	catch {
		$stat = 'ERROR'
		$msg = $_.Exception.Message -join ';'
	}
	finally {
		Write-Output $([pscustomobject]@{
			TestName    = $TestName
			TestGroup   = $TestGroup
			TestData    = $tempdata
			Description = $Description
			Status      = $stat 
			Message     = $msg
		})
	}
}
