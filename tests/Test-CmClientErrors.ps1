function Test-CmClientErrors {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Clients with Errors",
		[parameter()][string] $TestGroup = "operation",
		[parameter()][string] $TestCategory = "CM",
		[parameter()][string] $Description = "Check for clients reporting errors",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		$startTime = (Get-Date)
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat   = "PASS" # do not change this
		$except = "WARNING"
		$msg    = "No issues found" # do not change this either
		$query  = "SELECT DISTINCT
stat.MachineName,
fcm.SiteCode,
stat.Component,
stat.MessageID,
stat.MessageType,
stat.Severity
FROM v_StatusMessage stat
INNER JOIN v_FullCollectionMembership_Valid fcm ON fcm.Name = stat.MachineName
WHERE stat.Time > DATEADD(dd,-CONVERT(INT,7),GETDATE()) and
stat.Severity=0xC0000000 AND stat.PerClient!=0 AND fcm.CollectionID = 'SMS00001'
ORDER BY stat.MachineName"
		$res = Get-CmSqlQueryResult -Query $query -Params $ScriptParams
		if ($res.Count -gt 0) {
			$stat = $except
			$msg  = "$($res.Count) clients have reported errors"
			$res | Foreach-Object {
				$tempdata.Add(
					[pscustomobject]@{
						ComputerName = $_.MachineName
						Component = $_.Component
						MessageID = $_.MessageID
						MessageType = $_.MessageType
						Severity = $_.Severity
						SiteCode = $_.SiteCode
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
		$([pscustomobject]@{
			TestName    = $TestName
			TestGroup   = $TestGroup
			Category    = $TestCategory
			TestData    = $tempdata
			Description = $Description
			Status      = $stat
			Message     = $msg
			RunTime     = $(Get-RunTime -BaseTime $startTime)
			Credential  = $(if($ScriptParams.Credential){$($ScriptParams.Credential).UserName} else { $env:USERNAME })
		})
	}
}
