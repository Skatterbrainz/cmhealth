function Test-SqlAgentJobStatus {
	[CmdletBinding()]
	param (
		[parameter(Mandatory)][ValidateNotNullOrEmpty()][hashtable] $ScriptParams
	)
	Write-Verbose "test: sql agent job status"
	$HoursBack = 24
	try {
		$params = @{
			SqlInstance = $ScriptParams.SqlInstance 
			StartDate   = (Get-Date).AddHours(-$HoursBack)
		}
		$res = (Get-DbaAgentJobHistory @params | Where-Object {$_.Status -ne "Succeeded"})
		if ($res.Count -gt 0) { $result = 'FAIL' } else { $result = 'PASS' }
	}
	catch {
		$result = 'ERROR'
	}
	finally {
		$result
	}
}
