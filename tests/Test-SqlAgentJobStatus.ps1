function Test-SqlAgentJobStatus {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "SQL Agent Jobs",
		[parameter()][string] $TestGroup = "database",
		[parameter()][string] $Description = "Validate SQL Agent Job status",
		[parameter()][hashtable] $ScriptParams,
		[parameter()][int] $HoursBack = 24
	)
	try {
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat = "PASS"
		$msg = "No errors in the past $($HoursBack) hours"
		$params = @{
			SqlInstance = $ScriptParams.SqlInstance 
			StartDate   = (Get-Date).AddHours(-$HoursBack)
		}
		$res = @(Get-DbaAgentJobHistory @params | Where-Object {$_.Status -ne "Succeeded"})
		if ($res.Count -gt 0) { 
			$stat = 'FAIL' 
			$msg  = "$($res.Count) sql agent jobs failed within the past $HoursBack hours"
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
