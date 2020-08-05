function Test-CmBoundaries {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Test-CmBoundaries",
		[parameter()][string] $TestGroup = "configuration",
		[parameter()][string] $Description = "Validate Site Boundaries",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat = "PASS"
		$msg = "No issues found"
		$query = "select * from vSMS_Boundary"
		if ($ScriptParams.Credential) {
			$boundaries = @(Invoke-DbaQuery -SqlInstance $ScriptParams.SqlInstance -Database $ScriptParams.Database -Query $query -SqlCredential $ScriptParams.Credential)
		} else {
			$boundaries = @(Invoke-DbaQuery -SqlInstance $ScriptParams.SqlInstance -Database $ScriptParams.Database -Query $query)
		}
		
		$dupes = $boundaries | Group-Object -Property BoundaryType,Value | Select-Object Count,Name
		$orphaned = $boundaries | Where-Object {$_.GroupCount -eq 0}
		switch ($ScriptParams.Test) {
			'DuplicateBoundaries' {
				if (($dupes | Where-Object {$_.Count -gt 1}) -gt 0) {
					$stat = 'FAIL'
				}
			}
			'Orphaned' {
				if ($orphaned.Count -gt 1) {
					$stat = 'FAIL'
				}
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
			Credential  = $(if($ScriptParams.Credential){$($ScriptParams.Credential).UserName} else { $env:USERNAME })
		})
	}
}
