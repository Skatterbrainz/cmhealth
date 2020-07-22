function Test-CmUpdateADRErrors {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Test-CmUpdateADRErrors",
		[parameter()][string] $TestGroup = "operation",
		[parameter()][string] $Description = "Update ADR Rule Errors",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat = "PASS" # do not change this
		$msg  = "No issues found" # do not change this either
		$query = "SELECT Name, LastRunTime, LastErrorCode, LastErrorTime FROM vSMS_AutoDeployments WHERE LastErrorCode IS NOT NULL"
		$res = @(Invoke-DbaQuery -SqlInstance $ScriptParams.SqlInstance -Database $ScriptParams.Database -Query $query)
		if ($null -ne $res -and $res.Count -gt 0) {
			$stat = "WARNING" # or "FAIL"
			$msg  = "$($res.Count) items found: $($res.Name -join ',')"
			$res | Foreach-Object {$tempdata.Add("$($_.Name)=$($_.LastErrorCode)")}
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
