<#
.SYNOPSIS
	Confirm IIS Log files by age and volume
.DESCRIPTION
	Confirm IIS log file space utilization and age of files
.PARAMETER MaxDaysOld
	Number of days to keep log files (default is 30)
.PARAMETER MaxSpacePct
	Maximum percentage of total disk space to allow (default is 5)
.PARAMETER Remediate
	Apply remediation changes if required (delete old log files)
.EXAMPLE
	Test-IisLogFiles -MaxDaysOld 7 -Remediate
.NOTES
	
#>

function Test-IISLogFiles {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Descriptive Name",
		[parameter()][string] $TestGroup = "configuration",
		[parameter()][string] $Description = "Description of this test",
		[parameter()][bool] $Remediate = $False,
		[parameter()][ValidateRange(1, 366)][int] $MaxDaysOld = 30,
		[parameter()][ValidateRange(1, 90)][int] $MaxSpacePct = 5
	)
	try {
		<# 
		DELETE THIS COMMENT BLOCK WHEN FINISHED:
		perform test and return result as an object...
			$stat = 'PASS' or 'FAIL'
			$msg = "whatever you want to provide"
		#>
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		Import-Module WebAdministration 
		$LogsBase = $(Get-ItemProperty -Path 'IIS:\Sites\Default Web Site').logFile.directory -replace '%SystemDrive%', 'C:'
		$IISLogsPath = Join-Path $LogsBase -ChildPath "W3SVC1"
		$logs = Get-ChildItem -Path $IISLogsPath -Filter "*.log"
		$numlogs = $logs.Count
		Write-Verbose "$numlogs log files were found"
		$tsize = 0
		$logs | Select-Object -ExpandProperty Length | Foreach-Object { $tsize += $_ }
		$OldLogs = @($logs | Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-$MaxDaysOld) })
		$TotalSpaceMB = [math]::Round($tsize / 1MB, 2)
		if ($OldLogs.Count -gt 0) {
			if ($Remediate) {
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
		$totalDiskSize = $(Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID = 'C:'" | Select-Object -ExpandProperty Size) / 1MB
		$logSpaceUsed = [math]::Round($TotalSpaceMB / $totalDiskSize, 4)
		if (($logSpaceUsed * 100) -gt $MaxSpacePct) {
			$stat = "FAIL"
			$msg  = "IIS logs are using $TotalSpaceMB MB or $($logSpaceUsed * 100)`% of total capacity"
		} else {
			$stat = "PASS"
			$msg  = "IIS logs are using $TotalSpaceMB MB or $($logSpaceUsed * 100)`% of total capacity"
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
