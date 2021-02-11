function Test-SqlDbBackupHistory {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Test-SqlDbBackupHistory",
		[parameter()][string] $TestGroup = "configuration",
		[parameter()][string] $Description = "Validate CM SQL database backup history",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		$startTime = (Get-Date)
		[int]$DaysBack = Get-CmHealthDefaultValue -KeySet "sqlserver:SiteBackupMaxDaysOld" -DataSet $CmHealthConfig
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat   = "PASS"
		$except = "FAIL"
		$msg    = "No issues found"
		if ($null -ne $ScriptParams.Credential) {
			$bh = Get-DbaDbBackupHistory -SqlInstance $ScriptParams.SqlInstance -Database $ScriptParams.Database -Since (Get-Date).AddDays(-$DaysBack) -SqlCredential $ScriptParams.Credential
		} else {
			$bh = Get-DbaDbBackupHistory -SqlInstance $ScriptParams.SqlInstance -Database $ScriptParams.Database -Since (Get-Date).AddDays(-$DaysBack)
		}
		if ($bh.Count -lt 1) {
			$stat = $except
			$msg = "No backups were completed in the last $DaysBack days"
		} else {
			$lbu = $bh[0]
			if ($lbu.Type -ne "Full") {
				$stat = $except
				$msg = "Last backup was not a FULL backup"
			} else {
				$msg = "Last Full backup was at $($lbu.End)"
			}
		}
	}
	catch {
		$stat = 'ERROR'
		$msg = $_.Exception.Message -join ';'
	}
	finally {
		$endTime = (Get-Date)
		$runTime = $(New-TimeSpan -Start $startTime -End $endTime)
		$rt = "{0}h:{1}m:{2}s" -f $($runTime | Foreach-Object {$_.Hours,$_.Minutes,$_.Seconds})
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
