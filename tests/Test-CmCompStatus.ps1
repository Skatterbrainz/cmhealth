function Test-CmCompStatus {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Test-CmCompStatus",
		[parameter()][string] $TestGroup = "operation",
		[parameter()][string] $Description = "Check Component Status Error messages",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat = "PASS"
		$msg  = "No issues found"
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
		if ($ScriptParams.Credential) {
			$res = @(Invoke-DbaQuery -SqlInstance $ScriptParams.SqlInstance -Database $ScriptParams.Database -Query $query -SqlCredential $ScriptParams.Credential)
		} else {
			$res = @(Invoke-DbaQuery -SqlInstance $ScriptParams.SqlInstance -Database $ScriptParams.Database -Query $query)
		}
		if ($res.Count -gt 0) {
			$c1 = $($res | Where-Object Status -eq 'Critical').Count
			$c2 = $($res | Where-Object Status -eq 'Warning').Count
			if ($c1 -gt 0) {
				$stat = 'FAIL'
				$clist = $($res | Where-Object Status -eq 'Critical' | Select-Object -ExpandProperty ComponentName)
				$tempdata.Add("Critical=$($clist -join ';')")
			} elseif ($c2 -gt 0) {
				$stat = 'WARNING'
				$wlist = $($res | Where-Object Status -eq 'Warning' | Select-Object -ExpandProperty ComponentName)
				$tempdata.Add("Warning=$($wlist -join ';')")
			}
			$msg = "Component status since 12:00 = $c1 critical, $c2 warning out of $($res.count) total"
			$res | Foreach-Object {$tempdata.Add("$($_.ComponentName)=$($_.Errors)")}
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
			Credential  = $(if($ScriptParams.Credential){$($ScriptParams.Credential).UserName} else { $env:USERNAME })
		})
	}
}
