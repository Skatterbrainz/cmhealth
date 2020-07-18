function Test-Example {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Test-Example",
		[parameter()][string] $TestGroup = "configuration",
		[parameter()][string] $Description = "Description of this test",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat = "PASS" # do not change this
		$msg  = "No issues found" # do not change this either
		<# 
		DELETE THIS COMMENT BLOCK WHEN FINISHED:
		perform test and return result as an object...
			$stat = "FAIL" or "WARNING" (no need to set "PASS" since it's the default)
			$msg = (details of failure or warning)
			loop output into $tempdata.Add() array to return as TestData param in output
		#>

		<#
		# FOR SQL QUERY RELATED TESTS... DELETE THIS BLOCK IF NOT USED
		$query = ""
		$res = @(Invoke-DbaQuery -SqlInstance $ScriptParams.SqlInstance -Database $ScriptParams.Database -Query $query)
		if ($null -ne $res) {
			$stat = "WARNING" # or "FAIL"
			$msg  = "$($res.Count) items found: $($res.SoftwareName -join ',')"
		}
		#>
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
