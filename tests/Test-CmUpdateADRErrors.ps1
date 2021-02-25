function Test-CmUpdateADRErrors {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "ADR Errors",
		[parameter()][string] $TestGroup = "operation",
		[parameter()][string] $Description = "Check for ADR Rule Errors",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		$startTime = (Get-Date)
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat   = "PASS" # do not change this
		$except = "WARNING"
		$msg    = "No issues found" # do not change this either
		$query = "SELECT Name, LastRunTime, LastErrorCode, LastErrorTime FROM vSMS_AutoDeployments WHERE LastErrorCode IS NOT NULL"
		$res = Get-CmSqlQueryResult -Query $query -Params $ScriptParams
		if ($null -ne $res -and $res.Count -gt 0) {
			$stat = $except
			$msg  = "$($res.Count) items found: $($res.Name -join ',')"
			$res | Foreach-Object {
				$tempdata.Add(
					[pscustomobject]@{
						Name = $($_.Name)
						LastError = $($_.LastErrorCode)
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
