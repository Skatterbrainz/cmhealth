function Test-CmUpdateDeploymentErrors {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Test-CmUpdateDeploymentErrors",
		[parameter()][string] $TestGroup = "operation",
		[parameter()][string] $Description = "Update Deployment Error Messages",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat = "PASS" # do not change this
		$msg  = "No issues found" # do not change this either
		$query = "SELECT DISTINCT
fcm.ResourceID,
ISNULL(assc.LastEnforcementErrorCode,0) AS ErrorCode,
ISNULL(assc.LastEnforcementErrorCode,0) AS Message
FROM v_CIAssignment cia WITH (NOLOCK) 
JOIN v_UpdateAssignmentStatus_Live assc WITH (NOLOCK) ON assc.AssignmentID = cia.AssignmentID 
JOIN v_R_System sys WITH (NOLOCK) ON assc.ResourceID=sys.ResourceID AND ISNULL(sys.Obsolete0,0) <> 1 
JOIN v_FullCollectionMembership_Valid fcm WITH (NOLOCK) ON assc.ResourceID = fcm.ResourceID
WHERE assc.LastEnforcementErrorID & 0x0000FFFF <> 0 AND 
assc.LastEnforcementMessageID in (6,9) AND 
assc.IsCompliant=0 AND fcm.CollectionID = 'SMS00001'"
		$res = @(Invoke-DbaQuery -SqlInstance $ScriptParams.SqlInstance -Database $ScriptParams.Database -Query $query)
		if ($null -ne $res -and $res.Count -gt 0) {
			$stat = "WARNING" # or "FAIL"
			$msg  = "$($res.Count) items found: $($res.ErrorCode -join ',')"
			$res | Foreach-Object {$tempdata.Add("$($_.ErrorCode)=$($_.Message)")}
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
	