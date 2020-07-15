function Test-SqlUpdates {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "SQL Server Updates",
		[parameter()][string] $TestGroup = "database",
		[parameter()][string] $Description = "Verify SQL Updates and Service Packs",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat = "PASS"
		$res = Test-DbaBuild -Latest -SqlInstance $ScriptParams.SqlInstance -Update
		if ($res.Compliant -ne $True) { 
			$bcurrent = $res.BuildLevel
			$btarget  = $res.BuildTarget
			$stat = 'FAIL' 
			$msg = "SQL $($res.NameLevel) build level is $($bcurrent), but should be $($btarget): SP: $($res.SPTarget) CU: $($res.CULevel)"
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
