function Test-CmClientOldVersion {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Old Client Versions",
		[parameter()][string] $TestGroup = "operation",
		[parameter()][string] $Description = "Check for clients with version older than site version",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		$startTime = (Get-Date)
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat   = "PASS" # do not change this
		$except = "WARNING"
		$msg    = "No issues found" # do not change this either
		$query = "SELECT DISTINCT fcm.Name,
sys.Client_Version0 as ClientVersion,
fcm.Domain,
sys.User_Name0 as UserName,
fcm.SiteCode
FROM v_FullCollectionMembership_Valid fcm
INNER JOIN v_R_System_Valid sys ON fcm.ResourceID = sys.ResourceID
INNER JOIN v_Site st ON st.SiteCode = fcm.SiteCode
WHERE fcm.CollectionID = 'SMS00001' AND sys.Client_Version0 < st.Version"
		$res = Get-CmSqlQueryResult -Query $query -Params $ScriptParams
		if ($null -ne $res -and $res.Count -gt 0) {
			$stat = $except
			$msg  = "$($res.Count) items found: $($res.Name -join ',')"
			$res | Foreach-Object {
				$tempdata.Add(
					[pscustomobject]@{
						ComputerName = $($_.Name)
						Version = $($_.ClientVersion)
						UserName = $($_.UserName)
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
		Write-Output $([pscustomobject]@{
			TestName    = $TestName
			TestGroup   = $TestGroup
			TestData    = $tempdata
			Description = $Description
			Status      = $stat
			Message     = $msg
			RunTime     = $(Get-RunTime -BaseTime $startTime)
			Credential  = $(if($ScriptParams.Credential){$($ScriptParams.Credential).UserName} else { $env:USERNAME })
		})
	}
}
