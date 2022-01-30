function Test-CmUpdateDeploymentErrors {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Software Update Deployment Errors",
		[parameter()][string] $TestGroup = "operation",
		[parameter()][string] $TestCategory = "CM",
		[parameter()][string] $Description = "Update Deployment Error Messages",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		$startTime = (Get-Date)
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat   = "PASS" # do not change this
		$except = "WARNING"
		$msg    = "No issues found" # do not change this either
		$query = "SELECT DISTINCT
fcm.ResourceID,
fcm.Name,
sys.AD_Site_Name0 as ADSiteName,
sys.User_Name0 as UserName,
ISNULL(assc.LastEnforcementErrorCode,0) AS ErrorCode,
ISNULL(assc.LastEnforcementErrorCode,0) AS Message
FROM v_CIAssignment cia WITH (NOLOCK)
JOIN v_UpdateAssignmentStatus_Live assc WITH (NOLOCK) ON assc.AssignmentID = cia.AssignmentID
JOIN v_R_System sys WITH (NOLOCK) ON assc.ResourceID=sys.ResourceID AND ISNULL(sys.Obsolete0,0) <> 1
JOIN v_FullCollectionMembership_Valid fcm WITH (NOLOCK) ON assc.ResourceID = fcm.ResourceID
WHERE assc.LastEnforcementErrorID & 0x0000FFFF <> 0 AND
assc.LastEnforcementMessageID in (6,9) AND
assc.IsCompliant=0 AND fcm.CollectionID = 'SMS00001'
ORDER BY fcm.Name"
		$res = Get-CmSqlQueryResult -Query $query -Params $ScriptParams
		if ($res.Count -gt 0) {
			$stat = $except
			$msg  = "$($res.Count) deployment errors found"
			$res | Foreach-Object {
				$tempdata.Add(
					[pscustomobject]@{
						Resource  = $($_.ResourceID)
						Computer  = $($_.Name)
						UserName  = $($_.UserName)
						ADSite    = $($_.ADSiteName)
						ErrorCode = $($_.ErrorCode)
						HexCode = Convert-DecErrToHex -DecimalNumber $($_.ErrorCode)
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