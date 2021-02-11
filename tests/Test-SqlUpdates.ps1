function Test-SqlUpdates {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Test-SqlUpdates",
		[parameter()][string] $TestGroup = "database",
		[parameter()][string] $Description = "Verify SQL Updates and Service Packs",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		$startTime = (Get-Date)
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat   = "PASS"
		$except = "WARNING"
		$msg    = "No issues found"
		if ($null -ne $ScriptParams.Credential) {
			$res = Test-DbaBuild -Latest -SqlInstance $ScriptParams.SqlInstance -Update -SqlCredential $ScriptParams.Credential 
		} else {
			$res = Test-DbaBuild -Latest -SqlInstance $ScriptParams.SqlInstance -Update
		}
		if ($res.Compliant -ne $True) {
			$bcurrent = $res.BuildLevel
			$btarget  = $res.BuildTarget
			$stat = $except
			$msg = "SQL $($res.NameLevel) build level is $($bcurrent), but should be $($btarget): SP: $($res.SPTarget) CU: $($res.CULevel)"
		}
	}
	catch {
		$stat = 'ERROR'
		$msg = $_.Exception.Message -join ';'
	}
	finally {
		$rt = Get-RunTime -BaseTime $startTime
		Write-Output $([pscustomobject]@{
			TestName    = $TestName
			TestGroup   = $TestGroup
			TestData    = $tempdata
			Description = $Description
			Status      = $stat
			Message     = $msg
			RunTime     = $rt
			Credential  = $(if($ScriptParams.Credential){$($ScriptParams.Credential).UserName} else { $env:USERNAME })
		})
	}
}
