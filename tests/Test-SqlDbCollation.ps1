function Test-SqlDbCollation {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "SQL DB Collation",
		[parameter()][string] $TestGroup = "database",
		[parameter()][string] $Description = "Validate SQL database collation configruation",
		[parameter()][bool] $Remediate = $False,
		[parameter()][string] $SqlInstance = "localhost",
		[parameter()][string] $Database = "",
		[parameter()][string] $Collation = "SQL_Latin1_General_CP1_CI_AS"
	)
	try {
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat = "PASS"
		$msg  = "No issues found"
		$coll = Test-DbaDbCollation -SqlInstance $SqlInstance -Database $Database
		if ($coll.DatabaseCollation -ne $Collation) {
			$stat = "FAIL"
			$msg  = "Collection is $($coll.DatabaseCollation) but should be $Collation"
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
