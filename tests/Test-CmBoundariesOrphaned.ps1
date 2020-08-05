function Test-CmBoundaries {
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
		$query = "select * from vSMS_Boundary"
		if ($ScriptParams.Credential) {
			$boundaries = @(Invoke-DbaQuery -SqlInstance $ScriptParams.SqlInstance -Database $ScriptParams.Database -Query $query -SqlCredential $ScriptParams.Credential)
		} else {
			$boundaries = @(Invoke-DbaQuery -SqlInstance $ScriptParams.SqlInstance -Database $ScriptParams.Database -Query $query)
		}
		$orphaned = $boundaries | Where-Object {$_.GroupCount -eq 0}
		if ($orphaned.Count -gt 1) { $stat = 'FAIL' }
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
