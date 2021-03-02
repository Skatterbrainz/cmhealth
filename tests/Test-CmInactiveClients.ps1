function Test-CmInactiveClients {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Inactive Clients",
		[parameter()][string] $TestGroup = "operation",
		[parameter()][string] $Description = "Check for inactive clients",
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
CASE WHEN fcm.IsObsolete = 1 THEN '*' ELSE '' END AS Obsolete,
CASE WHEN fcm.IsBlocked = 1 THEN '*' ELSE '' END AS Blocked,
chs.LastActiveTime as LastContactTime,
fcm.SiteCode
FROM v_FullCollectionMembership fcm
INNER JOIN v_CH_ClientSummary chs ON chs.ResourceID = fcm.ResourceID AND chs.ClientActiveStatus = 0
WHERE fcm.CollectionID = 'SMS00001'"
		$res = Get-CmSqlQueryResult -Query $query -Params $ScriptParams
		if ($res.Count -gt 0) {
			$stat = $except
			$msg  = "$($res.Count) inactive clients were found"
			$res | Foreach-Object {
				$tempdata.Add(
					[pscustomobject]@{
						Name        = $_.Name
						SiteCode    = $_.SiteCode
						ResourceID  = $_.ResourceID
						Blocked     = $_.Blocked
						Obsolete    = $_.Obsolete
						LastContact = $_.LastContactTime
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
