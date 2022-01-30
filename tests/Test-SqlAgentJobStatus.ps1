function Test-SqlAgentJobStatus {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "SQL Agent Job Status",
		[parameter()][string] $TestGroup = "operation",
		[parameter()][string] $TestCategory = "SQL",
		[parameter()][string] $Description = "Validate SQL Agent Job status",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		$startTime = (Get-Date)
		[int]$HoursBack = Get-CmHealthDefaultValue -KeySet "sqlserver:SqlAgentJobStatusHoursBack" -DataSet $CmHealthConfig
		Write-Log -Message "hours back = $HoursBack"
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
			$res | Foreach-Object {
				$tempdata.Add(
					[pscustomobject]@{
						Name    = $_.Job
						Step    = $_.StepName
						RunDate = $_.RunDate
						Status  = $_.Status
						Message = $_.Message
					}
				)
			}
			$msg  = "$($res.Count) SQL Agent Jobs have failed within the past $HoursBack hours"
		}
	}
	catch {
		$stat = 'ERROR'
		$msg = $_.Exception.Message -join ';'
	}
	finally {
		Set-CmhOutputData
	}
}
