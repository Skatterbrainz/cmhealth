function Test-CmDbSize {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Check CM Site DB Size",
		[parameter()][string] $TestGroup = "database",
		[parameter()][string] $Description = "Validate CM site database file size",
		[parameter()][bool] $Remediate = $False,
		[parameter()][string] $SqlInstance = "localhost",
		[parameter()][string] $Database = ""
	)
	try {
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat = "PASS"
		$maxUtilization = 95
		$devices = Invoke-DbaQuery -SqlInstance $SqlInstance -Database $Database -Query "select distinct ResourceID,Name0 from v_R_System"
		Write-Verbose "calculating expected space requirements"
		$devSizeMB = (($devices.Count * 5MB) + 5GB) / 1MB
		Write-Verbose "expected space: $devSizeMB MB"
		$dbSizeMB = (Get-DbaDatabase -SqlInstance $SqlInstance -Database $Database).SizeMB
		Write-Verbose "actual space: $dbSizeMB MB"
		$pct = ([math]::Round($devSizeMB / $dbSizeMB, 1)) * 100
		Write-Verbose "actual utilization: $pct`%"
		if ($pct -gt $maxUtilization) {
			$stat = 'FAIL'
			$msg  = "Disk space is over allocated"
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
