function Test-SqlUpdates {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "SQL Server Update Status",
		[parameter()][string] $TestGroup = "configuration",
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
			Write-Log -Message "connecting with explicit credentials"
			$res = Test-DbaBuild -Latest -SqlInstance $ScriptParams.SqlInstance -Update -SqlCredential $ScriptParams.Credential 
		} else {
			Write-Log -Message "connecting with default credentials"
			$res = Test-DbaBuild -Latest -SqlInstance $ScriptParams.SqlInstance -Update
		}
		if ($null -eq $res) {
			$bcurrent = $null
			$btarget  = $null
			$stat     = "ERROR"
			$msg      = "Unable to connect to SQL instance ($($ScriptParams.SqlInstance))"
		} elseif ($res.Compliant -ne $True) {
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
		Write-Output $([pscustomobject]@{
			TestName    = $TestName
			TestGroup   = $TestGroup
			TestData    = $tempdata
			Description = $Description
			Status      = $stat
			Message     = $msg
			RunTime     = $(Get-RunTime -BaseTime $startTime)
			Credential  = $(if($ScriptParams.Credential){$($ScriptParams.Credential).UserName} else { $env:USERNAME })
		})
	}
}
