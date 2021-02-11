function Test-CmDbSize {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Test-CmDbSize",
		[parameter()][string] $TestGroup = "database",
		[parameter()][string] $Description = "Validate CM site database file size",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		$startTime = (Get-Date)
		[int]$maxUtilization = Get-CmHealthDefaultValue -KeySet "sqlserver:DatabaseFileSizeMaxPercent" -DataSet $CmHealthConfig
		[int]$PerDevData = Get-CmHealthDefaultValue -KeySet "sqlserver:DataSizePerCMClientMB" -DataSet $CmHealthConfig
		$maxUtilization = $maxUtilization * 0.1
		$devData = $PerDevData * 1MB
		Write-Verbose "Max Utilization Percent = $maxUtilization"
		Write-Verbose "Per Device Data MB = $PerDevData"
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat = "PASS"
		$except = "WARNING"
		$msg  = "Correct configuration"
		$query = "select distinct ResourceID,Name0 from v_R_System"
		if ($ScriptParams.Credential) {
			$devices = Invoke-DbaQuery -SqlInstance $ScriptParams.SqlInstance -Database $ScriptParams.Database -Query $query -SqlCredential $ScriptParams.Credential
		} else {
			$devices = Invoke-DbaQuery -SqlInstance $ScriptParams.SqlInstance -Database $ScriptParams.Database -Query $query
		}
		Write-Verbose "calculating expected space requirements"
		$devSizeMB = (($devices.Count * $devData) + $devData) / 1MB
		$recSize = $devSizeMB * $maxUtilization
		Write-Verbose "expected space: $devSizeMB MB (at $($devices.Count) devices)"
		if ($null -ne $ScriptParams.Credential) {
			$dbSizeMB = (Get-DbaDatabase -SqlInstance $ScriptParams.SqlInstance -Database $ScriptParams.Database -SqlCredential $ScriptParams.Credential).SizeMB 	
		} else {
			$dbSizeMB = (Get-DbaDatabase -SqlInstance $ScriptParams.SqlInstance -Database $ScriptParams.Database).SizeMB
		}
		Write-Verbose "actual space: $dbSizeMB MB"
		$pct = [math]::Round(($devSizeMB / $dbSizeMB) * 100, 1)
		Write-Verbose "actual utilization: $pct`%"
		if ($pct -gt $recSize) {
			$stat = $except
			$msg  = "Current DB size is $dbSizeMB MB ($pct percent of recommended). Recommended: $recSize MB"
		} else {
			$msg  = "Current DB size is $dbSizeMB MB ($pct percent of recommended). Recommended: $recSize MB"
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
