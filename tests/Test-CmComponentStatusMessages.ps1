function Test-CmComponentStatusMessages {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Component Status Exceptions",
		[parameter()][string] $TestGroup = "operation",
		[parameter()][string] $Description = "Get component status exception messages",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		$startTime = (Get-Date)
		[int] $DaysBack = Get-CmHealthDefaultValue -KeySet "configmgr:ComponentErrorsMaxDaysOld" -DataSet $CmHealthConfig
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat   = "PASS" # do not change this
		$except = "WARNING"
		$msg    = "No issues found" # do not change this either
		$query = "SELECT DISTINCT
sm.Component, sm.MessageID, sm.MachineName, sm.Severity, sm.MessageType, sma.AttributeValue
FROM dbo.vStatusMessages AS sm LEFT OUTER JOIN
dbo.v_StatMsgAttributes AS sma ON sm.RecordID = sma.RecordID
WHERE (sm.Severity IN (-1073741824, -2147483648)) AND
(sm.Component NOT IN ('Advanced Client', 'Windows Installer SourceList Update Agent',
'Desired Configuration Management', 'Software Updates Scan Agent',
'File Collection Agent', 'Hardware Inventory Agent',
'Software Distribution', 'Software Inventory Agent')) AND
(sm.Time >= DATEADD(dd, -CONVERT(INT,$($DaysBack)), GETDATE()))"
		$res = Get-CmSqlQueryResult -Query $query -Params $ScriptParams
		Write-Log -Message "returned $($res.Count) items"
		if ($res.Count -gt 0) {
			$stat = $except
			$msg  = "$($res.Count) items found within the last $DaysBack days"
			Write-Log -Message $msg
			$res | Foreach-Object {
				Write-Log -Message "$($_.Component) - $($_.MessageID) - $($_.MachineName)"
				$tempdata.Add(
					[pscustomobject]@{
						Component    = $_.Component
						MessageID    = $_.MessageID
						ComputerName = $_.MachineName
						Severity     = $_.Severity
						MessageType  = $_.MessageType
						Attribute    = $_.AttributeValue
					}
				)
			}
		} else {
			Write-Log -Message "no results were returned"
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
