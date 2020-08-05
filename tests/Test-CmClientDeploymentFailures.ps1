function Test-CmClientDeploymentFailures {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Test-CmClientDeploymentFailures",
		[parameter()][string] $TestGroup = "operation",
		[parameter()][string] $Description = "Check for failed client deployments",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat = "PASS" # do not change this
		$msg  = "No issues found" # do not change this either
		$query = "SELECT 
FQDN AS MachineNameFQDN, 
NetBiosName AS MachineName, 
ClientVersion AS ClientVersion, 
AssignedSiteCode AS SiteCode,
DeploymentBeginTime AS DeployStartTime, 
StateDescription AS FailureDescription, 
LastMessageParam AS DescriptionParam,
LastMessageStateID
FROM v_ClientDeploymentState 
WHERE LastMessageStateID < 100 AND LastMessageStateID > 400"
		if ($null -ne $ScriptParams.Credential) {
			$res = @(Invoke-DbaQuery -SqlInstance $ScriptParams.SqlInstance -Database $ScriptParams.Database -Query $query -SqlCredential $ScriptParams.Credential)
		} else {
			$res = @(Invoke-DbaQuery -SqlInstance $ScriptParams.SqlInstance -Database $ScriptParams.Database -Query $query)
		}
		
		if ($null -ne $res -and $res.Count -gt 0) {
			$stat = "WARNING" # or "FAIL"
			$msg  = "$($res.Count) items found: $($res.MachineName -join ',')"
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
