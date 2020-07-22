function Test-CmUpdateScanErrors {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Test-CmUpdateScanErrors",
		[parameter()][string] $TestGroup = "operation",
		[parameter()][string] $Description = "Update scanning errors",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat = "PASS" # do not change this
		$msg  = "No issues found" # do not change this either
		$query = "SELECT DISTINCT 
uss.ResourceID, uss.ScanTime, uss.LastScanState, uss.LastErrorCode, uss.LastWUAVersion, cdr.Name
FROM v_UpdateScanStatus AS uss INNER JOIN
v_CombinedDeviceResources AS cdr ON uss.ResourceID = cdr.MachineID
WHERE (uss.LastErrorCode <> 0)
ORDER BY cdr.Name"
		$res = @(Invoke-DbaQuery -SqlInstance $ScriptParams.SqlInstance -Database $ScriptParams.Database -Query $query)
		if ($null -ne $res -and $res.Count -gt 0) {
			$stat = "WARNING" # or "FAIL"
			$msg  = "$($res.Count) items found: $($res.Name -join ',')"
			$res | Foreach-Object {$tempdata.Add("Name=$($_.Name),ID=$($_.ResourceID),Error=$($_.LastErrorCode)")}
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
