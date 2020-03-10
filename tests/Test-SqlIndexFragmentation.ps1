[CmdletBinding()]
param (
	[parameter(Mandatory)][ValidateNotNullOrEmpty()][hashtable] $ScriptParams
)
Write-Verbose "test: sql index fragmentation status"
try {
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
	WHERE indexstats.database_id = DB_ID() and indexstats.avg_fragmentation_in_percent > $($ScriptParams.MinValue)
	ORDER BY indexstats.avg_fragmentation_in_percent desc"

	$res = (Invoke-DbaQuery -SqlInstance $ScriptParams.SqlInstance -Database $ScriptParams.Database -Query $query | ForEach-Object {
			[pscustomobject]@{
				Schema = $_.Schema
				Table  = $_.Table 
				Index  = $_.Index
				AvgFragPct = [math]::Round($_.avg_fragmentation_in_percent,2)
				PageCount  = $_.PageCount
			}
		})
	if ($res.Count -gt 1) { $result = 'FAIL' } else { $result = 'PASS' }
}
catch {
	$result = 'ERROR'
	Write-Error $_.Exception.Message
}
finally {
	$result
}