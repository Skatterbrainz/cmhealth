function Test-CmSiteLastBackup {
	[CmdletBinding()]
	[OutputType()]
	param (
		[parameter()][string] $TestName = "Last Site Backup",
		[parameter()][string] $TestGroup = "operation",
		[parameter()][string] $TestCategory = "CM",
		[parameter()][string] $Description = "Validate last ConfigMgr site backup status",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		$startTime = (Get-Date)
		[int]$DaysBack = Get-CmHealthDefaultValue -KeySet "sqlserver:SiteBackupMaxDaysOld" -DataSet $CmHealthConfig
		Write-Log -Message "threshold (days back) = $DaysBack"
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat   = "PASS"
		$except = "FAIL"
		$msg    = "No issues found"
		$query = "DECLARE @starttime as DATETIME,
@endtime AS DATETIME, @id as INT, @sitecode CHAR(3), @numberofdays INT
SET @sitecode = '$($ScriptParams.SiteCode)'
SET @numberofdays = $($DaysBack)
SELECT TOP 1 @starttime = smsgs.Time
FROM v_StatusMessage smsgs
WHERE
	smsgs.Time >= DATEADD(dd,-CONVERT(INT,@NumberofDays),GETDATE()) AND
	smsgs.MessageID = 5055 AND
	smsgs.sitecode = @sitecode
ORDER BY smsgs.Time DESC

SELECT TOP 1 @endtime = smsgs.Time, @id = smsgs.MessageID
FROM v_StatusMessage smsgs
WHERE
	smsgs.Time >= DATEADD(dd,-CONVERT(INT,@NumberofDays),GETDATE()) and
	smsgs.MessageID IN (5035, 5000, 5002, 5004, 5006, 5008, 5017, 5018, 5019, 5022, 5024, 5025, 5026, 5027, 5032, 5033, 5043, 5044, 5045, 5046, 5047, 5048, 5049, 5050, 5051, 5052, 5053) AND
	smsgs.sitecode = @sitecode
ORDER BY smsgs.Time DESC

IF (@starttime IS NOT NULL)
SELECT @starttime AS StartTime,
CASE
	WHEN (@starttime > @endtime) THEN NULL
	ELSE @endtime
END AS EndTime,
CASE
	WHEN (@starttime > @endtime) THEN 'Last Backup did not finish'
	WHEN (@endtime is NULL) THEN 'Last Backup did not finish'
	WHEN (@id = 5035) THEN 'SMS Site Backup completed successfully with zero errors but still there could be some warnings'
	WHEN (@id != 5035) THEN 'SMS Site Backup failed to completed successfully'
END AS 'Comments'"
		#Write-Log -Message "submitting the following query to the SQL instance:"
		#Write-Log -Message $query
		$res = Get-CmSqlQueryResult -Query $query -Params $ScriptParams
		if ($null -eq $res) {
			$stat = $except
			$msg = "No backup status found. Verify backups are enabled."
		} else {
			if ($res.Comments -notmatch "completed successfully with zero") {
				$stat = $except
				$msg  = "$($res.Comments)"
			} else {
				$msg = $res.Comments
			}
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
