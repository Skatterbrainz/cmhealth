function Test-CmBoundariesOrphaned {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Test-CmBoundariesOrphaned",
		[parameter()][string] $TestGroup = "configuration",
		[parameter()][string] $Description = "Validate Site Boundaries are in Boundary Groups",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat  = "PASS"
		$msg   = "No issues found"
		$query = "select * from vSMS_Boundary where GroupCount < 1"
		if ($ScriptParams.Credential) {
			$res = @(Invoke-DbaQuery -SqlInstance $ScriptParams.SqlInstance -Database $ScriptParams.Database -Query $query -SqlCredential $ScriptParams.Credential)
		} else {
			$res = @(Invoke-DbaQuery -SqlInstance $ScriptParams.SqlInstance -Database $ScriptParams.Database -Query $query)
		}
		if ($res.Count -gt 1) { 
			$stat = 'WARNING'
			$msg = "$($res.Count) boundaries found not in a boundary group" 
			$res | Foreach-Object {$tempdata.Add(@("Name=$($_.DisplayName)","Scope=$($_.Value)"))}
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
