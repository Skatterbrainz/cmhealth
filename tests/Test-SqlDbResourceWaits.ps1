function Test-SqlDbResourceWaits {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Test-SqlDbResourceWaits",
		[parameter()][string] $TestGroup = "database",
		[parameter()][string] $Description = "Description of this test",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat = "PASS"
		$msg  = "No issues found"
		$query = "SELECT 
CAST(100.0 * SUM(signal_wait_time_ms) / SUM (wait_time_ms) AS NUMERIC(20,2)) AS [CPUWaits_Pct],
CAST(100.0 * SUM(wait_time_ms - signal_wait_time_ms) / SUM (wait_time_ms) AS NUMERIC(20,2)) AS [ResourceWaits_Pct] 
FROM sys.dm_os_wait_stats OPTION (RECOMPILE)"
		$res = (Invoke-DbaQuery -SqlInstance $ScriptParams.SqlInstance -Database $ScriptParams.Database -Query $query)
		if ($res.CPUWaits_Pct -gt 10 -or $res.ResourceWaits_Pct -gt 50) {
			$stat = "FAIL"
			$msg = "Excessive CPU waits: CPU=$($res.CPUWaits_Pct) Resources=$($res.ResourceWaits_Pct)"
			$res | Foreach-Object {$tempdata.Add("CPUWaits=$($_.CPUWaits_Pct),ResWaits=$($_.ResourceWaits_Pct)")}
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
