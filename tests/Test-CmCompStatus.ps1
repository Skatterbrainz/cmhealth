function Test-CmCompStatus {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Check Component Status",
		[parameter()][string] $TestGroup = "operation",
		[parameter()][string] $Description = "Check Component Status Error messages",
		[parameter()][hashtable] $ScriptParams,
		[parameter()][int] $BackDays = 2
	)
	try {
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat = "PASS"
		$msg  = "No issues found"
		$FromDate = (Get-Date).AddDays(-$BackDays).ToString('yyyy-MM-dd')
		$query = "select * from vSMS_ComponentSummarizer where LastContacted > '$($FromDate)' and Errors > 0"
		$comps = (Invoke-DbaQuery -SqlInstance $ScriptParams.SqlInstance -Database $ScriptParams.Database -Query $query)
		if ($comps.Count -gt 0) {
			$stat = "FAIL"
			$msg  = "$($comps.Count) Component Status Errors were found in the last"
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

