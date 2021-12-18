function Test-CmUpdateScanErrors {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Clients with Update Scan Errors",
		[parameter()][string] $TestGroup = "operation",
		[parameter()][string] $TestCategory = "CM",
		[parameter()][string] $Description = "Update scanning errors",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		$startTime = (Get-Date)
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat   = "PASS" # do not change this
		$except = "WARNING"
		$msg    = "No issues found" # do not change this either
		$query = "SELECT DISTINCT
uss.ResourceID, uss.ScanTime, uss.LastScanState, uss.LastErrorCode, uss.LastWUAVersion, cdr.Name
FROM v_UpdateScanStatus AS uss INNER JOIN
v_CombinedDeviceResources AS cdr ON uss.ResourceID = cdr.MachineID
WHERE (uss.LastErrorCode <> 0)
ORDER BY cdr.Name"
		$res = Get-CmSqlQueryResult -Query $query -Params $ScriptParams
		if ($res.Count -gt 0) {
			$stat = $except
			$msg  = "$($res.Count) update scan errors were found"
			$res | Foreach-Object {
				$tempdata.Add(
					[pscustomobject]@{
						Name     = $_.Name
						ID       = $_.ResourceID
						Error    = $_.LastErrorCode
						LastScan = $_.ScanTime
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
		$([pscustomobject]@{
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
