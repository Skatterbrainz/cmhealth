function Test-CmClientErrors {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Test-CmClientErrors",
		[parameter()][string] $TestGroup = "operation",
		[parameter()][string] $Description = "Check for clients reporting errors",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat = "PASS" # do not change this
		$msg  = "No issues found" # do not change this either
		$query = "SELECT DISTINCT
stat.MachineName,
fcm.SiteCode,
stat.Component
FROM v_StatusMessage stat
INNER JOIN v_FullCollectionMembership_Valid fcm ON fcm.Name = stat.MachineName
WHERE stat.Time > DATEADD(dd,-CONVERT(INT,7),GETDATE()) and
stat.Severity=0xC0000000 AND stat.PerClient!=0 AND fcm.CollectionID = 'SMS00001'"
		if ($ScriptParams.Credential) {
			$res = @(Invoke-DbaQuery -SqlInstance $ScriptParams.SqlInstance -Database $ScriptParams.Database -Query $query -SqlCredential $ScriptParams.Credential)
		} else {
			$res = @(Invoke-DbaQuery -SqlInstance $ScriptParams.SqlInstance -Database $ScriptParams.Database -Query $query)
		}
		if ($null -ne $res -and $res.Count -gt 0) {
			$stat = "WARNING" # or "FAIL"
			$msg  = "$($res.Count) items found: $($res.MachineName -join ',')"
			$res | Foreach-Object {$tempdata.Add(@($_.MachineName, $_.Component))}
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
