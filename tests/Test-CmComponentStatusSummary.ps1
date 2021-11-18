function Test-CmComponentStatusSummary {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Component Status Summary",
		[parameter()][string] $TestGroup = "operation",
		[parameter()][string] $TestCategory = "CM",
		[parameter()][string] $Description = "Check Component Status summary counts",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		$startTime = (Get-Date)
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat   = "PASS"
		$except = "FAIL"
		$msg    = "No issues found"
		$query = "SELECT
ComponentName, Errors, Infos, Warnings,
CASE WHEN Status = 0 THEN 'OK'
	WHEN Status = 1 THEN 'Warning'
	WHEN Status = 2 THEN 'Critical'
END AS Status
FROM v_ComponentSummarizer
WHERE
TallyInterval='0001128000100008' AND
SiteCode = '$($ScriptParams.SiteCode)' AND
Errors > 0"
		$res = Get-CmSqlQueryResult -Query $query -Params $ScriptParams
		if ($res.Count -gt 0) {
			$c1 = $($res | Where-Object Status -eq 'Critical').Count
			$c2 = $($res | Where-Object Status -eq 'Warning').Count
			if ($c1 -gt 0) {
				$stat = $except
			} elseif ($c2 -gt 0) {
				$stat = 'WARNING'
			}
			$msg = "Component status since 12:00 = $c1 critical, $c2 warning out of $($res.count) total"
			$res | Foreach-Object {
				$tempdata.Add(
					[pscustomobject]@{
						Component = $_.ComponentName
						Errors = $_.Errors
						Status = $_.Status
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
