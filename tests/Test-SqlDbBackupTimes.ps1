function Test-SqlDbBackupTimes {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Test-SqlDbBackupTimes",
		[parameter()][string] $TestGroup = "configuration",
		[parameter()][string] $Description = "Check for backups that took too long to finish",
		[parameter()][hashtable] $ScriptParams,
		[parameter()][int] $DaysBack = 7,
		[parameter()][int] $MaxRunTime = 300
	)
	try {
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat = "PASS"
		$msg  = "No issues found"
		$query = "Select * From (
SELECT 
s.database_name AS [Database],
CASE s.[type]
WHEN 'D' THEN 'Full'
WHEN 'I' THEN 'Differential'
WHEN 'L' THEN 'Transaction Log'
END AS BackupType,
CAST(CAST(s.backup_size / 1000000 AS INT) AS VARCHAR(14)) + ' ' + 'MB' AS Size,
DATEDIFF(second, s.backup_start_date, s.backup_finish_date) Seconds,
s.backup_start_date AS StartDate
FROM msdb.dbo.backupset s
INNER JOIN msdb.dbo.backupmediafamily m ON s.media_set_id = m.media_set_id
WHERE 
s.backup_start_date >= DATEADD(dd,-CONVERT(INT, $DaysBack),GETDATE()) 
) T1
WHERE T1.Seconds > $MaxRunTime
ORDER BY T1.Seconds DESC"
		$res = @(Invoke-DbaQuery -SqlInstance $ScriptParams.SqlInstance -Database $ScriptParams.Database -Query $query)
		if ($res.Count -gt 0) {
			$stat = "WARNING"
			$msg = "$($res.Count) backups took longer than $MaxRunTime seconds"
			$res | Foreach-Object {$tempdata.Add( "$($_.Database)=$($_.Seconds) sec") }
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