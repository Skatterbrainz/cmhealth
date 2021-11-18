function Test-SqlDatabaseFileInfo {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "SQL Instance Database File Info",
		[parameter()][string] $TestGroup = "operation",
		[parameter()][string] $TestCategory = "SQL",
		[parameter()][string] $Description = "Database and Log file sizes and growth settings",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		$startTime = (Get-Date)
		#[int]$Setting = Get-CmHealthDefaultValue -KeySet "keygroup:keyname" -DataSet $CmHealthConfig
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat   = "PASS" # do not change this
		$except = "WARNING" # or "FAIL"
		$msg    = "No issues found" # do not change this either
		$query = "CREATE TABLE ##temp_DatabaseAnalysis 
(DatabaseName sysname, Name sysname, physical_name NVARCHAR(500), size DECIMAL (18,2), FreeSpace DECIMAL (18,2) )   
EXEC sp_msforeachdb '
USE [?];
INSERT INTO ##temp_DatabaseAnalysis (DatabaseName, Name, physical_name, Size, FreeSpace)
    SELECT DB_NAME() AS [DatabaseName], Name,  physical_name,
    CAST(CAST(ROUND(CAST(size as decimal) * 8.0/1024.0,2) as DECIMAL(18,2)) AS NVARCHAR) Size,
    CAST(CAST(ROUND(CAST(size as decimal) * 8.0/1024.0,2) as DECIMAL(18,2)) - CAST(FILEPROPERTY(name, ''SpaceUsed'') * 8.0/1024.0 as DECIMAL(18,2)) as NVARCHAR) As FreeSpace
    FROM sys.database_files
'
SELECT db.name, db.recovery_model_desc, 
CASE 
    WHEN mf.type_desc = 'ROWS' THEN 'Database'
    ELSE 'Logs'
END AS type_desc, mf.physical_name, 
(mf.size*8)/1024 as Size, 
CASE 
    WHEN mf.max_size = -1 THEN 'Unlimited'
    ELSE CAST(mf.max_size as VARCHAR(200))
END AS Max_Size,
tmp.FreeSpace, 
CASE
    WHEN mf.is_percent_growth = 1 THEN CAST(mf.growth as VARCHAR(200)) + '%'
    ELSE CAST(mf.growth as VARCHAR(200)) + ' MB'
END AS Growth,
(SELECT COUNT(1) FROM sys.master_files mf1 WHERE mf1.type_desc = 'ROWS' AND db.database_id = mf1.database_id ) AS CountDataFile,
(SELECT COUNT(1) FROM sys.master_files mf1 WHERE mf1.type_desc = 'LOG' AND db.database_id = mf1.database_id ) AS CountLogFile
FROM sys.master_files mf INNER JOIN sys.databases db ON db.database_id = mf.database_id
INNER JOIN ##temp_DatabaseAnalysis tmp ON mf.physical_name = tmp.physical_name
DROP TABLE ##temp_DatabaseAnalysis"
		$res = Get-CmSqlQueryResult -Query $query -Params $ScriptParams
		$res | Foreach-Object {
			$tempdata.Add(
				[PSCustomObject]@{
					Name         = $_.Name
					RecoverModel = $_.recovery_model_desc
					Type         = $_.type_desc
					FilePath     = $_.physical_name
					SizeMB       = $_.Size
					MaxSizeMB    = $_.Max_Size
					FreeSpaceMB  = $_.FreeSpace
					Growth       = $_.Growth
					DBFiles      = $_.CountDataFile
					LogFiles     = $_.CountLogFile
				}
			)
		}
		if ($res.Count -gt 0) {
			$stat = $except
			$msg  = "$($res.Count) items found"
			#$res | Foreach-Object {$tempdata.Add( [pscustomobject]@{Name=$_.Name} )}
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
			Category    = $TestCategory
			TestData    = $tempdata
			Description = $Description
			Status      = $stat
			Message     = $msg
			RunTime     = $(Get-RunTime -BaseTime $startTime)
			Credential  = $(if($ScriptParams.Credential){$($ScriptParams.Credential).UserName} else { $env:USERNAME })
		})
	}
}
