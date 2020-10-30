function Test-SqlDbRecoveryModel {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Test-SqlDbRecoveryModel",
		[parameter()][string] $TestGroup = "database",
		[parameter()][string] $Description = "Validate database recovery model settings",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		[string]$DefaultModel = Get-CmHealthDefaultValue -KeySet "sqlserver:RecoveryModel" -DataSet $CmHealthConfig
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat = "PASS"
		$msg  = "Correct configuration"
		if ($ScriptParams.Credential) {
			$rm = (Get-DbaDbRecoveryModel -SqlInstance $ScriptParams.SqlInstance -Database $ScriptParams.Database -ErrorAction SilentlyContinue -SqlCredential $ScriptParams.Credential).RecoveryModel
		} else {
			$rm = (Get-DbaDbRecoveryModel -SqlInstance $ScriptParams.SqlInstance -Database $ScriptParams.Database -ErrorAction SilentlyContinue).RecoveryModel
		}
		if ($rm -ne $DefaultModel) {
			if ($Remediate -eq $True) {
				if ($ScriptParams.Credential) {
					$null = Set-DbaDbRecoveryModel -SqlInstance $ScriptParams.SqlInstance -Database $ScriptParams.Database -RecoveryModel $DefaultModel -ErrorAction SilentlyContinue -SqlCredential $ScriptParams.Credential 
				} else {
					$null = Set-DbaDbRecoveryModel -SqlInstance $ScriptParams.SqlInstance -Database $ScriptParams.Database -RecoveryModel $DefaultModel -ErrorAction SilentlyContinue
				}
				$stat = "REMEDIATED"
				$msg  = "Recovery model is now to $DefaultModel"
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
			Credential  = $(if($ScriptParams.Credential){$($ScriptParams.Credential).UserName} else { $env:USERNAME })
		})
	}
}
