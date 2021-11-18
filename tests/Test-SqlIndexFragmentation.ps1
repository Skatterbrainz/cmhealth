function Test-SqlIndexFragmentation {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "SQL Database Index Fragmentation Status",
		[parameter()][string] $TestGroup = "operation",
		[parameter()][string] $TestCategory = "SQL",
		[parameter()][string] $Description = "Validate SQL database index fragmentation status",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		$startTime = (Get-Date)
		[int]$MinValue = Get-CmHealthDefaultValue -KeySet "sqlserver:IndexFragThresholdPercent" -DataSet $CmHealthConfig
		Write-Log -Message "min index fragmentation pct = $MinValue"
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat   = "PASS"
		$except = "WARNING"
		$msg    = "No indexes were fragmented more than $MinValue percent"
		$query = "SELECT dbschemas.[name] as 'Schema',
dbtables.[name] as 'Table',
dbindexes.[name] as 'Index',
indexstats.avg_fragmentation_in_percent,
indexstats.page_count
FROM sys.dm_db_index_physical_stats (DB_ID(), NULL, NULL, NULL, NULL) AS indexstats
INNER JOIN sys.tables dbtables on dbtables.[object_id] = indexstats.[object_id]
INNER JOIN sys.schemas dbschemas on dbtables.[schema_id] = dbschemas.[schema_id]
INNER JOIN sys.indexes AS dbindexes ON dbindexes.[object_id] = indexstats.[object_id]
AND indexstats.index_id = dbindexes.index_id
WHERE indexstats.database_id = DB_ID() and indexstats.avg_fragmentation_in_percent > $($MinValue)
ORDER BY indexstats.avg_fragmentation_in_percent desc"
		$res = Get-CmSqlQueryResult -Query $query -Params $ScriptParams
		$result = $res | ForEach-Object {
				[pscustomobject]@{
					Schema = $_.Schema
					Table  = $_.Table
					Index  = $_.Index
					AvgFragPct = [math]::Round($_.avg_fragmentation_in_percent,2)
					PageCount  = $_.PageCount
				}
		}
		if ($result.Count -gt 1) {
			$stat = $except
			$msg = "$($result.Count) indexes were fragmented more than $MinValue percent"
			$result | Foreach-Object {
				$tempdata.Add(
					[pscustomobject]@{
						Table = $($_.Table)
						Index = $($_.Index)
						FragPct=$($_.AvgFragPct)
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
