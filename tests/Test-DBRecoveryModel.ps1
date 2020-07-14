function Test-DBRecoveryModel {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Validate DB Recovery Model",
		[parameter()][string] $TestGroup = "database",
		[parameter()][string] $Description = "Validate database recovery model settings",
		[parameter()][bool] $Remediate = $False,
		[parameter()][string] $SqlInstance = "localhost",
		[parameter()][string] $Database = ""
	)
	try {
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat = "PASS"
		$msg  = "Correct configuration"
		$rm = (Get-DbaDbRecoveryModel -SqlInstance $SqlInstance -Database $Database -ErrorAction SilentlyContinue).RecoveryModel
		if ($rm -ne 'Simple') {
			if ($Remediate -eq $True) {
				$null = Set-DbaDbRecoveryModel -SqlInstance $SqlInstance -Database $Database -RecoveryModel "Simple" -ErrorAction SilentlyContinue
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
