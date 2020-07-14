function Test-SqlDbFileGrowth {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Descriptive Name",
		[parameter()][string] $TestGroup = "configuration",
		[parameter()][string] $Description = "Description of this test",
		[parameter()][bool] $Remediate = $False,
		[parameter()][string] $SqlInstance = "localhost",
		[parameter()][string] $Database = ""
	)
	try {
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat = "PASS"
		<# 
		DELETE THIS COMMENT BLOCK WHEN FINISHED:
		perform test and return result as an object...
			$stat = 'PASS' or 'FAIL'
			$msg = "whatever you want to provide"
		#>
		$dbfiles = Get-DbaDbFile -SqlInstance $SqlInstance -Database $Database
		switch ($ScriptParams.FileType) {
			'Database' {
				$files = $dbfiles | Where-Object {$_.TypeDescription -eq 'Rows'}
				$test1 = $files | Where-Object {$_.GrowthType -eq 'Percent' -and $_.Growth -ge 10}
				$test2 = $files | Where-Object {$_.GrowthType -eq '' -and $_.Growth -ge 256}
				# more work needed here!
			}
			'Log' {
				# more work needed here!
			}
		} # switch
		
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
