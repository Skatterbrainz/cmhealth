function Test-CmWsusLastSync {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Test-CmWsusLastSync",
		[parameter()][string] $TestGroup = "operation",
		[parameter()][string] $Description = "Validate last WSUS synchronization result",
		[parameter()][hashtable] $ScriptParams,
		[parameter()][int] $DaysBack = 7
	)
	try {
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat = "PASS"
		$msg  = "No issues found"
		$query = "DECLARE @starttime AS DATETIME, @endtime AS DATETIME, @id AS INT, @sitecode CHAR(3)
SELECT @sitecode = '$($ScriptParams.SiteCode)'
SELECT TOP 1 @starttime = smsgs.Time
FROM v_StatusMessage smsgs 
WHERE
	smsgs.Time >= DATEADD(dd,-CONVERT(INT,$($DaysBack)),GETDATE()) AND 
	smsgs.MessageID = 6701 AND 
	smsgs.sitecode = @sitecode
ORDER BY smsgs.Time DESC

SELECT TOP 1 @endtime = smsgs.Time, @id = smsgs.MessageID
FROM v_StatusMessage smsgs 
WHERE
	smsgs.Time >= DATEADD(dd,-CONVERT(INT,$($DaysBack)),GETDATE()) AND 
	smsgs.MessageID IN (6702, 6703) AND 
	smsgs.sitecode = @sitecode
ORDER BY smsgs.Time DESC

IF (@starttime IS NOT NULL) AND (@endtime IS NOT NULL)
SELECT @starttime as StartTime,
CASE 
	WHEN (@starttime > @endtime) THEN NULL
	ELSE @endtime
END AS EndTime, 
CASE 
	WHEN (@starttime > @endtime) THEN 'Last WSYS Sync did not finish'
	WHEN (@id = 6702) THEN 'Success'
	WHEN (@id = 6703) THEN 'Error'
END AS 'Comments'"
		if ($ScriptParams.Credential) {
			$res = (Invoke-DbaQuery -SqlInstance $ScriptParams.SqlInstance -Database $ScriptParams.Database -Query $query -SqlCredential $ScriptParams.Credential)
		} else {
			$res = (Invoke-DbaQuery -SqlInstance $ScriptParams.SqlInstance -Database $ScriptParams.Database -Query $query)
		}
		if ($null -eq $res) {
			throw "No status found. Confirm SUP and WSUS are configured."
		} else {
			if ($res.Comments -ne 'Success') {
				$stat = "FAIL"
				$msg = "Status = $($res.Comments)"
			}
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
			Credential  = $(if($ScriptParams.Credential){$($ScriptParams.Credential).UserName} else { $env:USERNAME })
		})
	}
}
