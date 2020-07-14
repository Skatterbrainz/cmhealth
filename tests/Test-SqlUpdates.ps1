function Test-SqlUpdates {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "SQL Server Updates",
		[parameter()][string] $TestGroup = "database",
		[parameter()][string] $Description = "Verify SQL Updates and Service Packs",
		[parameter()][bool] $Remediate = $False,
		[parameter()][string] $SqlInstance = "localhost",
		[parameter()][string] $Database = ""
	)
	try {
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat = "PASS"
		$res = Test-DbaBuild -Latest -SqlInstance $ScriptParams.SqlInstance
		if ($res.Compliant -ne $True) { $stat = 'FAIL' }
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
