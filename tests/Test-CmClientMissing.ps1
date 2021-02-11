function Test-CmClientMissing {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Test-CmClientMissing",
		[parameter()][string] $TestGroup = "operation",
		[parameter()][string] $Description = "Check for discovered machines without a client",
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
fcm.SiteCode,
fcm.Domain,
sys.Operating_System_Name_and0
FROM v_FullCollectionMembership fcm
INNER JOIN v_R_System sys ON fcm.ResourceID = sys.ResourceID
WHERE fcm.IsClient != 1 AND fcm.Name NOT LIKE '%Unknown%' AND fcm.CollectionID = 'SMS00001'
AND sys.Operating_System_Name_and0 IS NOT NULL AND sys.Operating_System_Name_and0 <> ''"
		$res = Get-CmSqlQueryResult -Query $query -Params $ScriptParams
		if ($null -ne $res -and $res.Count -gt 0) {
			$stat = $except
			$msg  = "$($res.Count) items found: $($res.Name -join ',')"
			$res | Foreach-Object {$tempdata.Add("Name=$($_.Name),SiteCode=$($_.SiteCode)")}
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
