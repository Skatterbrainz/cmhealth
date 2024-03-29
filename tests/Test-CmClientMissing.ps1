function Test-CmClientMissing {
	[CmdletBinding()]
	[OutputType()]
	param (
		[parameter()][string] $TestName = "Missing Clients",
		[parameter()][string] $TestGroup = "operation",
		[parameter()][string] $TestCategory = "CM",
		[parameter()][string] $Description = "Check for discovered devices without a client",
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
sys.Operating_System_Name_and0 as OSName
FROM v_FullCollectionMembership fcm
INNER JOIN v_R_System sys ON fcm.ResourceID = sys.ResourceID
WHERE fcm.IsClient != 1 AND fcm.Name NOT LIKE '%Unknown%' AND fcm.CollectionID = 'SMS00001'
AND sys.Operating_System_Name_and0 IS NOT NULL AND sys.Operating_System_Name_and0 <> ''
ORDER BY fcm.Name"
		$res = Get-CmSqlQueryResult -Query $query -Params $ScriptParams
		if ($res.Count -gt 0) {
			$stat = $except
			$msg  = "$($res.Count) devices are missing a ConfigMgr client"
			Write-Log -Message $msg
			$res | Foreach-Object {
				$tempdata.Add(
					[pscustomobject]@{
						ComputerName = $($_.Name)
						ResourceID = $($_.ResourceID)
						Domain = $($_.Domain)
						OS = $($_.OSName)
						SiteCode = $($_.SiteCode)
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
