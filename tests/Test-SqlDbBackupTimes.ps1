function Test-SqlDbBackupTimes {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "SQL Database Backup Times",
		[parameter()][string] $TestGroup = "operation",
		[parameter()][string] $Description = "Check for backups that took too long to finish",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		$startTime = (Get-Date)
		[int] $DaysBack = Get-CmHealthDefaultValue -KeySet "sqlserver:SiteBackupMaxDaysOld" -DataSet $CmHealthConfig
		[int] $MaxRunTime = Get-CmHealthDefaultValue -KeySet "wsus:SiteBackupMaxRuntime" -DataSet $CmHealthConfig
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat   = "PASS"
		$except = "WARNING"
		$msg    = "No issues found"
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
		if ($null -ne $ScriptParams.Credential) {
			$res = @(Invoke-DbaQuery -SqlInstance $ScriptParams.SqlInstance -Database $ScriptParams.Database -Query $query -SqlCredential $ScriptParams.Credential)
		} else {
			$res = @(Invoke-DbaQuery -SqlInstance $ScriptParams.SqlInstance -Database $ScriptParams.Database -Query $query)
		}
		if ($res.Count -gt 0) {
			$stat = $except
			$msg = "$($res.Count) backups took longer than $MaxRunTime seconds"
			$res | Foreach-Object {
				$tempdata.Add(
					[pscustomobject]@{
						Database = $_.Database
						BackupType = $_.BackupType
						Size = $_.Size
						StartDate = $_.StartDate
						Duration = "$($_.Seconds) sec"
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
