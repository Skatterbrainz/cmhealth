function Test-SqlDatabaseFileGrowth {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "SQL Database File Growth",
		[parameter()][string] $TestGroup = "configuration",
		[parameter()][string] $TestCategory = "SQL",
		[parameter()][string] $Description = "Results of SQL file auto-growth configuration",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		$startTime = (Get-Date)
		#[int]$Setting = Get-CmHealthDefaultValue -KeySet "keygroup:keyname" -DataSet $CmHealthConfig
		$MaxRunTimeSeconds = 30
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat   = "PASS" # do not change this
		$except = "WARNING" # or "FAIL"
		$msg    = "No issues found" # do not change this either
		$query = "SELECT 
s.database_name,
CASE s.[type]
WHEN 'D' THEN 'Full'
WHEN 'I' THEN 'Differential'
WHEN 'L' THEN 'Transaction Log'
END AS BackupType,
CAST(CAST(s.backup_size / 1000000 AS INT) AS VARCHAR(14)) + ' ' + 'MB' AS bkSize,
CAST(DATEDIFF(second, s.backup_start_date,
s.backup_finish_date) AS VARCHAR(4)) + ' ' + 'Seconds' TimeTaken,
s.backup_start_date
FROM msdb.dbo.backupset s
INNER JOIN msdb.dbo.backupmediafamily m ON s.media_set_id = m.media_set_id
WHERE 
s.backup_start_date >= DATEADD(dd,-CONVERT(INT,7),GETDATE()) 
ORDER BY s.database_name, backup_finish_date DESC, backup_start_date ASC"
		$res = Get-CmSqlQueryResult -Query $query -Params $ScriptParams
		$res | Foreach-Object {
			if ($_.TimeTaken -gt $MaxRunTimeSeconds) {
				$stat = $except
				$msg = "one or more growth tasks took longer than $MaxRunTimeSeconds seconds"
			}
			$tempdata.Add(
				[pscustomobject]@{
					Database = $_.database_name
					BackupType = $_.BackupType
					BackupSize = $_.bkSize
					RunTime = $_.TimeTaken
					BackupStart = $_.backup_start_date
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
