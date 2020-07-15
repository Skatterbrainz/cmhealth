function Test-SqlDbBackupHistory {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Validate CM SQL DB Backup History",
		[parameter()][string] $TestGroup = "configuration",
		[parameter()][string] $Description = "Validate CM SQL database backup history",
		[parameter()][hashtable] $ScriptParams,
		[parameter()][int] $DaysBack = 7
	)
	try {
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat = "PASS"
		$msg  = "No issues found"
		$bh = Get-DbaDbBackupHistory -SqlInstance $ScriptParams.SqlInstance -Database $ScriptParams.Database -Since (Get-Date).AddDays(-$DaysBack)
		if ($bh.Count -lt 1) {
			$stat = "FAIL"
			$msg = "No backups were completed in the last $DaysBack days"
		} else {
			$lbu = $bh[0]
			if ($lbu.Type -ne "Full") {
				$stat = "FAIL"
				$msg = "Last backup was not a FULL backup"
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
