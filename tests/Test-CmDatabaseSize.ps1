function Test-CmDatabaseSize {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Database Size",
		[parameter()][string] $TestGroup = "database",
		[parameter()][string] $TestCategory = "CM",
		[parameter()][string] $Description = "Validate CM site database file size",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		$startTime = (Get-Date)
		[int]$maxUtilization = Get-CmHealthDefaultValue -KeySet "sqlserver:DatabaseFileSizeMaxPercent" -DataSet $CmHealthConfig
		[int]$PerDevData = Get-CmHealthDefaultValue -KeySet "sqlserver:DataSizePerCMClientMB" -DataSet $CmHealthConfig
		$maxUtilization = $maxUtilization * 0.1
		$devData = $PerDevData * 1MB
		Write-Log -Message "Max Utilization Percent = $maxUtilization"
		Write-Log -Message "Per Device Data MB = $PerDevData"
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat    = "PASS"
		$except  = "WARNING"
		$msg     = "Correct configuration"
		$query   = "select distinct ResourceID,Name0 from v_R_System"
		$devices = Get-CmSqlQueryResult -Query $query -Params $ScriptParams
		Write-Log -Message "calculating expected space requirements"
		$devSizeMB = (($devices.Count * $devData) + $devData) / 1MB
		$recSize = $devSizeMB * $maxUtilization
		Write-Log -Message "expected space: $devSizeMB MB (at $($devices.Count) devices)"
		if ($null -ne $ScriptParams.Credential) {
			$dbSizeMB = (Get-DbaDatabase -SqlInstance $ScriptParams.SqlInstance -Database $ScriptParams.Database -SqlCredential $ScriptParams.Credential).SizeMB
		} else {
			$dbSizeMB = (Get-DbaDatabase -SqlInstance $ScriptParams.SqlInstance -Database $ScriptParams.Database).SizeMB
		}
		Write-Log -Message "rounding result to precision 2"
		$dbSizeMB = [math]::Round($dbSizeMB,2)
		Write-Log -Message "actual space: $dbSizeMB MB"
		$pct = [math]::Round(($devSizeMB / $dbSizeMB) * 100, 1)
		Write-Log -Message "actual utilization: $pct`%"
		if ($pct -gt $recSize) {
			$stat = $except
			$msg  = "Current DB size is $dbSizeMB MB ($pct percent of recommended). Recommended: $recSize MB"
		} else {
			$msg  = "Current DB size is $dbSizeMB MB ($pct percent of recommended). Recommended: $recSize MB"
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
