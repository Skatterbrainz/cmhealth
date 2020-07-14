function Test-CmBoundaries {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Validate Site Boundaries",
		[parameter()][string] $TestGroup = "configuration",
		[parameter()][string] $Description = "Validate Site Boundaries",
		[parameter()][bool] $Remediate = $False,
		[parameter()][string] $SqlInstance = "localhost",
		[parameter()][string] $Database = ""
	)
	try {
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat = "PASS"
		$msg = "No issues found"
		$query = "select * from vSMS_Boundary"
		$boundaries = Invoke-DbaQuery -SqlInstance $SqlInstance -Database $Database -Query $query
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
		})
	}
}
