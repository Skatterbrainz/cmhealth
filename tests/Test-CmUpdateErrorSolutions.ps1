function Test-CmUpdateErrorSolutions {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Software Update Error Solutions",
		[parameter()][string] $TestGroup = "operations",
		[parameter()][string] $TestCategory = "CM",
		[parameter()][string] $Description = "Update Error Solution Details",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		$startTime = (Get-Date)
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat   = "PASS" # do not change this
		$except = "WARNING"
		$msg    = "No issues found" # do not change this either
		$query = "SELECT DISTINCT
assc.LastEnforcementErrorCode as ErrorCode,
assc.LastEnforcementMessageID as Message
FROM v_CIAssignment cia WITH (NOLOCK)
JOIN v_UpdateAssignmentStatus_Live assc WITH (NOLOCK) on assc.AssignmentID = cia.AssignmentID 
JOIN v_R_System sys WITH (NOLOCK) on assc.ResourceID=sys.ResourceID AND ISNULL(sys.Obsolete0,0) <> 1
JOIN v_FullCollectionMembership_Valid fcm WITH (NOLOCK) on assc.ResourceID = fcm.ResourceID
WHERE assc.LastEnforcementErrorID <> 0
AND assc.LastEnforcementMessageID in (6,9)
AND assc.IsCompliant=0
AND fcm.CollectionID = 'SMS00001'"
		$res = Get-CmSqlQueryResult -Query $query -Params $ScriptParams
		if ($null -ne $res -and $res.Count -gt 0) {
			$stat = $except
			$msg  = "$($res.Count) items were found"
			$res | Foreach-Object {
				$tempdata.Add(
					[pscustomobject]@{
						Error   = $($_.ErrorCode)
						Message = $($_.Message)
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
