function Test-CmUpdateErrorSolutions {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Test-CmUpdateErrorSolutions",
		[parameter()][string] $TestGroup = "operations",
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
WHERE
assc.LastEnforcementErrorID <> 0
AND assc.LastEnforcementMessageID in (6,9)
AND assc.IsCompliant=0
AND fcm.CollectionID = 'SMS00001'"
		if ($null -ne $ScriptParams.Credential) {
			$res = @(Invoke-DbaQuery -SqlInstance $ScriptParams.SqlInstance -Database $ScriptParams.Database -Query $query -SqlCredential $ScriptParams.Credential)
		} else {
			$res = @(Invoke-DbaQuery -SqlInstance $ScriptParams.SqlInstance -Database $ScriptParams.Database -Query $query)
		}
		if ($null -ne $res -and $res.Count -gt 0) {
			$stat = $except
			$msg  = "$($res.Count) items found: $($res.ErrorCode -join ',')"
			$res | Foreach-Object {$tempdata.Add([pscustomobject]@{Error=$($_.ErrorCode);Message=$($_.Message)})}
		}
	}
	catch {
		$stat = 'ERROR'
		$msg = $_.Exception.Message -join ';'
	}
	finally {
		$endTime = (Get-Date)
		$runTime = $(New-TimeSpan -Start $startTime -End $endTime)
		$rt = "{0}h:{1}m:{2}s" -f $($runTime | Foreach-Object {$_.Hours,$_.Minutes,$_.Seconds})
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
