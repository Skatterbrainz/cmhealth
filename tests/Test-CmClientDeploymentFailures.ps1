function Test-CmClientDeploymentFailures {
	[CmdletBinding()]
	[OutputType()]
	param (
		[parameter()][string] $TestName = "Client Deployment Failures",
		[parameter()][string] $TestGroup = "operation",
		[parameter()][string] $TestCategory = "CM",
		[parameter()][string] $Description = "Check for failed client deployments",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		$startTime = (Get-Date)
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat   = "PASS" # do not change this
		$except = "WARNING"
		$msg    = "No issues found" # do not change this either
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
		$res = Get-CmSqlQueryResult -Query $query -Params $ScriptParams
		if ($null -ne $res -and $res.Count -gt 0) {
			$stat = $except
			$msg  = "$($res.Count) items found: $($res.MachineName -join ',')"
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
