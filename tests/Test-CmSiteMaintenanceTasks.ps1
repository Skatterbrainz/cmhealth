function Test-CmSiteMaintenanceTasks {
	[CmdletBinding()]
	[OutputType()]
	param (
		[parameter()][string] $TestName = "Check Site Maintenance Tasks",
		[parameter()][string] $TestGroup = "configuration",
		[parameter()][string] $TestCategory = "CM",
		[parameter()][string] $Description = "Check site maintenance task settings",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		$startTime = (Get-Date)
		$MaxDisabled = 2
		#[int]$Setting = Get-CmHealthDefaultValue -KeySet "keygroup:keyname" -DataSet $CmHealthConfig
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat   = "PASS" # do not change this
		$except = "WARNING" # or "FAIL"
		$msg    = "No issues found" # do not change this either
		$query = "SELECT TaskName, 
CASE IsEnabled WHEN 1 THEN 'YES' 
ELSE 'NO' 
END AS IsEnabled, 
CASE DeleteOlderThan WHEN 0 THEN NULL ELSE DeleteOlderThan END AS DeleteOlderThan, 
CASE BeginTime WHEN 0 THEN '0:00' ELSE LEFT(CONVERT(VARCHAR(4), BeginTime),(CASE WHEN (LEN(BeginTime)-2) <=0 THEN 0 ELSE (LEN(BeginTime)-2) END)) + ':' + RIGHT(CONVERT(VARCHAR(4), BeginTime),2) END AS BeginTime,
CASE LatestBeginTime WHEN 0 THEN '0:00' ELSE LEFT(CONVERT(VARCHAR(4), LatestBeginTime),(CASE WHEN (LEN(LatestBeginTime)-2) <=0 THEN 0 ELSE (len(LatestBeginTime)-2) END)) + ':' + RIGHT(CONVERT(VARCHAR(4), LatestBeginTime),2) END AS LatestBeginTime,
ISNULL((CASE CAST(DaysOfWeek & 1 as bit) WHEN 1 THEN 'Sunday, ' END), '') +
ISNULL((CASE CAST(DaysOfWeek & 2 as bit) WHEN 1 THEN 'Monday, ' END), '') +
ISNULL((CASE CAST(DaysOfWeek & 4 as bit) WHEN 1 THEN 'Tuesday, ' END), '') +
ISNULL((CASE CAST(DaysOfWeek & 8 as bit) WHEN 1 THEN 'Wednesday, ' END), '') +
ISNULL((CASE CAST(DaysOfWeek & 16 as bit) WHEN 1 THEN 'Thursday, ' END), '') +
ISNULL((CASE CAST(DaysOfWeek & 32 as bit) WHEN 1 THEN 'Friday, ' END), '') +
ISNULL((CASE CAST(DaysOfWeek & 64 as bit) WHEN 1 THEN 'Saturday' END), '') AS DaysOfWeek 
FROM vSMS_SC_SQL_Task WHERE SiteCode = '$($ScriptParams.SiteCode)'"
		$res = Get-CmSqlQueryResult -Query $query -Params $ScriptParams
		$disabled = $res | Where-Object {$_.IsEnabled -ne 'YES'}
		if ($disabled.Count -gt $MaxDisabled) {
			$stat = $except
		}
		$msg = "$($disabled.Count) of $($res.Count) maintenance tasks are disabled"
		$res | Foreach-Object {
			$tempdata.Add(
				[pscustomobject]@{
					TaskName = $_.TaskName
					Enabled  = $_.IsEnabled
					DeleteOlderThan = $_.DeleteOlderThan
					StartTime   = $_.BeginTime
					LatestStart = $_.LatestBeginTime
					DaysOfWeek  = $_.DaysOfWeek
				}
			)
		}
	}
	catch {
		$stat = 'ERROR'
		$msg = $_.Exception.Message -join ';'
	}
	finally {
		Set-CmhOutputData
	}
}
