function Test-HostIISLogFiles {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Test-HostIISLogFiles",
		[parameter()][string] $TestGroup = "configuration",
		[parameter()][string] $Description = "Validate IIS Log File retention",
		[parameter()][hashtable] $ScriptParams,
		[parameter()][ValidateRange(1, 366)][int] $MaxDaysOld = 30,
		[parameter()][ValidateRange(1, 90)][int] $MaxSpacePct = 5
	)
	try {
		$stat = "PASS"
		$msg  = "No issues found"
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		if (!(Get-Module WebAdministration -ListAvailable)) { throw "WebAdministration module not installed. Please install RSAT" }
		Import-Module WebAdministration 
		$LogsBase = $(Get-Item 'IIS:\Sites\Default Web Site').logfile.directory -replace '%SystemDrive%', "$($env:SYSTEMDRIVE)"
		#$LogsBase = $(Get-ItemProperty -Path 'IIS:\Sites\Default Web Site').logFile.directory -replace '%SystemDrive%', 'C:'
		$IISLogsPath = Join-Path $LogsBase -ChildPath "W3SVC1"
		$logs = Get-ChildItem -Path $IISLogsPath -Filter "*.log"
		$numlogs = $logs.Count
		Write-Verbose "$numlogs log files were found"
		$tsize = 0
		$logs | Select-Object -ExpandProperty Length | Foreach-Object { $tsize += $_ }
		$OldLogs = @($logs | Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-$MaxDaysOld) })
		$TotalSpaceMB = [math]::Round($tsize / 1MB, 2)
		if ($OldLogs.Count -gt 0) {
			Write-Verbose "$($oldLogs.Count) older log files were found"
			if ($Remediate -eq $True) {
				$OldLogs | Select-Object -ExpandProperty FullName | Remove-Item -Force
				$stat = "REMEDIATED"
				$msg  = "deleted $($OldLogs.Count) of $numlogs IIS logs older than $MaxDaysOld days old"
			} else {
				$stat = "FAIL"
				$msg  = "$($OldLogs.Count) of $numlogs IIS logs older than $MaxDaysOld days old"
			}
		} else {
			$stat = "PASS"
			$msg  = "there are no IIS logs older than $MaxDaysOld days old"
		}
		$tempdata.Add([pscustomobject]@{
			Status = $stat
			Message = $msg
		})
		$totalDiskSize = $(Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID = 'C:'" | Select-Object -ExpandProperty Size) / 1MB
		$logSpaceUsed = [math]::Round($TotalSpaceMB / $totalDiskSize, 4)
		if (($logSpaceUsed * 100) -gt $MaxSpacePct) {
			$stat = "FAIL"
			$msg  = "IIS logs are using $TotalSpaceMB MB or $($logSpaceUsed * 100)`% of total capacity"
		} else {
			$stat = "PASS"
			$msg  = "IIS logs are using $TotalSpaceMB MB or $($logSpaceUsed * 100)`% of total capacity"
		}
		$tempdata.Add([pscustomobject]@{
			Status = $stat
			Message = $msg
		})
		$result = [pscustomobject]@{
			TestName    = $TestName
			TestGroup   = $TestGroup
			TestData    = $tempdata
			Description = $Description
			Status      = $stat 
			Message     = $msg
			Credential  = $(if($ScriptParams.Credential){$($ScriptParams.Credential).UserName} else { $env:USERNAME })
		}
	}
	catch {
		$result = [pscustomobject]@{
			TestName    = $TestName
			TestGroup   = $TestGroup
			TestData    = $tempdata
			Description = $Description
			Status   = 'ERROR'
			Activity = $($_.CategoryInfo.Activity -join(";"))
			Message  = $($_.Exception.Message -join(";"))
			Trace    = $($_.ScriptStackTrace -join(";"))
			RunAs    = $($env:USERNAME)
			RunOn    = $($env:COMPUTERNAME)
			Credential  = $(if($ScriptParams.Credential){$($ScriptParams.Credential).UserName} else { $env:USERNAME })
		}
	}
	finally {
		Write-Output $result
	}
}
