function Test-CmClientAssignmentFailures {
	[CmdletBinding()]
	[OutputType()]
	param (
		[parameter()][string] $TestName = "Client Assignment Failures",
		[parameter()][string] $TestGroup = "operation",
		[parameter()][string] $TestCategory = "CM",
		[parameter()][string] $Description = "Check for clients that failed site assignment",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		$startTime = (Get-Date)
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat   = "PASS" # do not change this
		$except = "WARNING"
		$msg    = "No issues found" # do not change this either
		$query  = "SELECT
FQDN AS MachineNameFQDN,
NetBiosName AS MachineName,
ClientVersion AS ClientVersion,
AssignedSiteCode AS SiteCode,
AssignmentBeginTime AS AssignmentStartTime,
StateDescription AS FailureDescription,
LastMessageParam AS DescriptionParam,
LastMessageStateID
FROM v_ClientDeploymentState
WHERE LastMessageStateID > 500 AND LastMessageStateID < 700"
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
