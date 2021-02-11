function Test-CmClientUpdateDeploymentErrors {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Test-CmClientUpdateDeploymentErrors",
		[parameter()][string] $TestGroup = "operation",
		[parameter()][string] $Description = "Check for clients with software update deployment errors",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		$startTime = (Get-Date)
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat   = "PASS" # do not change this
		$except = "WARNING"
		$msg    = "No issues found" # do not change this either
		$query = "SELECT DISTINCT
sys.Name0 AS MachineName,
sys.Client_Version0 AS SMSClientVersion,
sys.User_Name0 AS LastLoggedOnUser,
assc.LastEnforcementMessageTime AS LastEnforcementTime,
assc.LastEnforcementErrorID & 0x0000FFFF AS ErrorStatusID,
isnull(assc.LastEnforcementErrorCode,0) AS ErrorCode,
fcm.SiteCode
FROM v_CIAssignment cia WITH (NOLOCK)
JOIN v_UpdateAssignmentStatus_Live assc WITH (NOLOCK) ON assc.AssignmentID = cia.AssignmentID
JOIN v_R_System sys WITH (NOLOCK) ON assc.ResourceID=sys.ResourceID and isnull(sys.Obsolete0,0) <> 1
JOIN v_FullCollectionMembership_Valid fcm WITH (NOLOCK) ON assc.ResourceID = fcm.ResourceID
WHERE assc.LastEnforcementErrorID & 0x0000FFFF <> 0 AND
assc.LastEnforcementMessageID IN (6,9) AND assc.IsCompliant=0 AND
fcm.CollectionID = 'SMS00001'"
		$res = Get-CmSqlQueryResult -Query $query -Params $ScriptParams
		if ($null -ne $res -and $res.Count -gt 0) {
			$stat = $except
			$msg  = "$($res.Count) items found: $($res.MachineName -join ',')"
			$res | Foreach-Object {$tempdata.Add(@($_.MachineName, $_.ErrorCode))}
		}
	}
	catch {
		$stat = 'ERROR'
		$msg = $_.Exception.Message -join ';'
	}
	finally {
		$rt = Get-RunTime -BaseTime $startTime
		Write-Output $([pscustomobject]@{
			TestName    = $TestName
			TestGroup   = $TestGroup
			TestData    = $tempdata
			Description = $Description
			Status      = $stat
			Message     = $msg
			RunTime     = $rt
			Credential  = $(if($ScriptParams.Credential){$($ScriptParams.Credential).UserName} else { $env:USERNAME })
		})
	}
}
