function Test-SqlDbRecoveryModel {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "SQL Database Recovery Models",
		[parameter()][string] $TestGroup = "configuration",
		[parameter()][string] $Description = "Validate database recovery model settings",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		$startTime = (Get-Date)
		[string]$DefaultModel = Get-CmHealthDefaultValue -KeySet "sqlserver:RecoveryModel" -DataSet $CmHealthConfig
		Write-Log -Message "default recovery model = $DefaultModel"
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat   = "PASS"
		$except = "FAIL"
		$msg    = "Correct configuration"
		if ($null -ne $ScriptParams.Credential) {
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
				$stat = $except
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
			RunTime     = $(Get-RunTime -BaseTime $startTime)
			Credential  = $(if($ScriptParams.Credential){$($ScriptParams.Credential).UserName} else { $env:USERNAME })
		})
	}
}
