function Test-SqlAgentJobStatus {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Test-SqlAgentJobStatus",
		[parameter()][string] $TestGroup = "database",
		[parameter()][string] $Description = "Validate SQL Agent Job status",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		$startTime = (Get-Date)
		[int]$HoursBack = Get-CmHealthDefaultValue -KeySet "sqlserver:SqlAgentJobStatusHoursBack" -DataSet $CmHealthConfig
		Write-Verbose "hours back = $HoursBack"
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat   = "PASS"
		$except = "FAIL"
		$msg = "No errors in the past $($HoursBack) hours"
		if ($null -ne $ScriptParams.Credential) {
			$params = @{
				SqlInstance   = $ScriptParams.SqlInstance 
				StartDate     = (Get-Date).AddHours(-$HoursBack)
				SqlCredential = $ScriptParams.Credential
			}
		} else {
			$params = @{
				SqlInstance = $ScriptParams.SqlInstance 
				StartDate   = (Get-Date).AddHours(-$HoursBack)
			}
		}
		$res = @(Get-DbaAgentJobHistory @params | Where-Object {$_.Status -ne "Succeeded"})
		if ($res.Count -gt 0) {
			$stat = $except
			$msg  = "$($res.Count) sql agent jobs failed within the past $HoursBack hours"
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
