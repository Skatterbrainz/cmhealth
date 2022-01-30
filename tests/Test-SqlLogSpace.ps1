function Test-SqlLogSpace {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "SQL Log Space Usage",
		[parameter()][string] $TestGroup = "operation",
		[parameter()][string] $TestCategory = "SQL",
		[parameter()][string] $Description = "Check for SQL logs with excessive space used",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		$startTime = (Get-Date)
		#[int]$Setting = Get-CmHealthDefaultValue -KeySet "keygroup:keyname" -DataSet $CmHealthConfig
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat   = "PASS" # do not change this
		$except = "WARNING" # or "FAIL"
		$msg    = "No issues found" # do not change this either
		$logs   = Get-DbaDbLogSpace -SqlInstance $ScriptParams.SqlInstance
		foreach ($log in $logs) {
			if ($log.LogSpaceUsedPercent -gt 50) {
				Write-Log -Message "log space warning: $($log.Database)"
				$msg = "Log space warning (greater than 50 percent used)"
				$stat = $except
				$tempdata.Add(
					[pscustomobject]@{
						Instance = $log.SqlInstance
						Database = $log.Database
						LogSize  = $log.LogSize
						PercentUsed  = $log.LogSpaceUsedPercent
						LogSpaceUsed = $log.LogSpaceUsed
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
		Set-CmhOutputData
	}
}
