function Test-SqlDbRecoveryModel {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Test-SqlDbRecoveryModel",
		[parameter()][string] $TestGroup = "database",
		[parameter()][string] $Description = "Validate database recovery model settings",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat = "PASS"
		$msg  = "Correct configuration"
		$rm = (Get-DbaDbRecoveryModel -SqlInstance $ScriptParams.SqlInstance -Database $ScriptParams.Database -ErrorAction SilentlyContinue).RecoveryModel
		if ($rm -ne 'Simple') {
			if ($Remediate -eq $True) {
				$null = Set-DbaDbRecoveryModel -SqlInstance $ScriptParams.SqlInstance -Database $ScriptParams.Database -RecoveryModel "Simple" -ErrorAction SilentlyContinue
				$stat = "REMEDIATED"
				$msg  = "Recovery model is now to SIMPLE"
			} else {
				$stat = "FAIL"
				$msg  = "Recovery model is currently set to $rm"
			}
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
