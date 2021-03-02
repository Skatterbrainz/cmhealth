function Test-SqlDbResourceWaits {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "SQL Database Resource Wait Times",
		[parameter()][string] $TestGroup = "operation",
		[parameter()][string] $Description = "Check for excessive resource wait times",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		$startTime = (Get-Date)
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat   = "PASS"
		$except = "WARNING"
		$msg    = "No issues found"
		$query = "SELECT
CAST(100.0 * SUM(signal_wait_time_ms) / SUM (wait_time_ms) AS NUMERIC(20,2)) AS [CPUWaits_Pct],
CAST(100.0 * SUM(wait_time_ms - signal_wait_time_ms) / SUM (wait_time_ms) AS NUMERIC(20,2)) AS [ResourceWaits_Pct]
FROM sys.dm_os_wait_stats OPTION (RECOMPILE)"
		$res = Get-CmSqlQueryResult -Query $query -Params $ScriptParams
		if ($res.CPUWaits_Pct -gt 10 -or $res.ResourceWaits_Pct -gt 50) {
			$stat = $except
			$msg = "Excessive CPU waits: CPU=$($res.CPUWaits_Pct) Resources=$($res.ResourceWaits_Pct)"
			$res | Foreach-Object {
				$tempdata.Add(
					[pscustomobject]@{
						SqlInstance = $ScriptParams.SqlInstance
						CPUWaits = $($_.CPUWaits_Pct)
						ResourceWaits = $($_.ResourceWaits_Pct)
					}
				)
			}
		}
	}
	catch {
		$stat = 'ERROR'
		$msg = $_.Exception.Message -join ';'
	}
	finally {
		$rt = Get-RunTime -BaseTime $startTime
		Write-Output $([pscustomobject]@{
			TestName    = $TestName
			TestGroup   = $TestGroup
			TestData    = $tempdata
			Description = $Description
			Status      = $stat
			Message     = $msg
			RunTime     = $rt
			Credential  = $(if($ScriptParams.Credential){$($ScriptParams.Credential).UserName} else { $env:USERNAME })
		})
	}
}
