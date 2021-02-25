function Test-CmClientErrors {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Clients with Errors",
		[parameter()][string] $TestGroup = "operation",
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
stat.Component
FROM v_StatusMessage stat
INNER JOIN v_FullCollectionMembership_Valid fcm ON fcm.Name = stat.MachineName
WHERE stat.Time > DATEADD(dd,-CONVERT(INT,7),GETDATE()) and
stat.Severity=0xC0000000 AND stat.PerClient!=0 AND fcm.CollectionID = 'SMS00001'"
		$res = Get-CmSqlQueryResult -Query $query -Params $ScriptParams
		if ($null -ne $res -and $res.Count -gt 0) {
			$stat = $except
			$msg  = "$($res.Count) items found: $($res.MachineName -join ',')"
			$res | Foreach-Object {$tempdata.Add(@($_.MachineName, $_.Component))}
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
