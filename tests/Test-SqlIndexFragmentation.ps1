function Test-SqlIndexFragmentation {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Test-SqlIndexFragmentation",
		[parameter()][string] $TestGroup = "database",
		[parameter()][string] $Description = "Validate SQL database index fragmentation status",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		[int]$MinValue = Get-CmHealthDefaultValue -KeySet "sqlserver:IndexFragThresholdPercent" -DataSet $CmHealthConfig
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat = "PASS"
		$msg = "No indexes were fragmented more than $MinValue percent"
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
		if ($ScriptParams.Credential) {
			$res = (Invoke-DbaQuery -SqlInstance $ScriptParams.SqlInstance -Database $ScriptParams.Database -Query $query -SqlCredential $ScriptParams.Credential)
		} else {
			$res = (Invoke-DbaQuery -SqlInstance $ScriptParams.SqlInstance -Database $ScriptParams.Database -Query $query)
		}
		$res = $res | ForEach-Object {
				[pscustomobject]@{
					Schema = $_.Schema
					Table  = $_.Table 
					Index  = $_.Index
					AvgFragPct = [math]::Round($_.avg_fragmentation_in_percent,2)
					PageCount  = $_.PageCount
				}
		}
		if ($res.Count -gt 1) { 
			$stat = 'WARNING' 
			$msg = "$($res.Count) indexes were fragmented more than $MinValue percent"
			$res | Foreach-Object {$tempdata.Add("Table=$($_.Table),Index=$($_.Index),FragPct=$($_.AvgFragPct)") }
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
