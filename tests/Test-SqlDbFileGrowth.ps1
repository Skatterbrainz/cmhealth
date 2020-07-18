function Test-SqlDbFileGrowth {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Test-SqlDbFileGrowth",
		[parameter()][string] $TestGroup = "database",
		[parameter()][string] $Description = "Validate SQL Database File Auto-Growth settings",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat = "PASS"
		$msg = "No issues found"
		$dbfiles = Get-DbaDbFile -SqlInstance $ScriptParams.SqlInstance -Database $ScriptParams.Database
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
