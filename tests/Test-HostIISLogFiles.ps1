function Test-HostIISLogFiles {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "IIS Log Files",
		[parameter()][string] $TestGroup = "configuration",
		[parameter()][string] $TestCategory = "HOST",
		[parameter()][string] $Description = "Validate IIS Log File retention",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		$startTime = (Get-Date)
		[int]$MaxDaysOld  = Get-CmHealthDefaultValue -KeySet "iis:LogFilesMaxDaysOld" -DataSet $CmHealthConfig
		[int]$MaxSpacePct = Get-CmHealthDefaultValue -KeySet "iis:LogFilesMaxSpacePercent" -DataSet $CmHealthConfig
		Write-Log -Message "MaxDaysOld = $MaxDaysOld"
		Write-Log -Message "MaxSpacePct = $MaxSpacePct"

		$stat   = "PASS"
		$except = "WARNING"
		$msg    = "No issues found"

		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		if (!(Get-Module WebAdministration -ListAvailable)) { throw "WebAdministration module not installed. Please install RSAT" }
		Import-Module WebAdministration
		$LogsBase = $(Get-Item 'IIS:\Sites\Default Web Site').logfile.directory -replace '%SystemDrive%', "$($env:SYSTEMDRIVE)"
		#$LogsBase = $(Get-ItemProperty -Path 'IIS:\Sites\Default Web Site').logFile.directory -replace '%SystemDrive%', 'C:'
		$IISLogsPath = Join-Path $LogsBase -ChildPath "W3SVC1"
		$logs = Get-ChildItem -Path $IISLogsPath -Filter "*.log"
		$numlogs = $logs.Count
		Write-Log -Message "$numlogs log files were found"
		$tsize = 0
		$logs | Select-Object -ExpandProperty Length | Foreach-Object { $tsize += $_ }
		$OldLogs = @($logs | Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-$MaxDaysOld) })
		$TotalSpaceMB = [math]::Round($tsize / 1MB, 2)
		if ($OldLogs.Count -gt 0) {
			Write-Log -Message "$($oldLogs.Count) older log files were found"
			if ($Remediate -eq $True) {
				$OldLogs | Select-Object -ExpandProperty FullName | Remove-Item -Force
				$stat = "REMEDIATED"
				$msg  = "deleted $($OldLogs.Count) of $numlogs IIS logs older than $MaxDaysOld days old"
			} else {
				$stat = $except
				$msg  = "$($OldLogs.Count) of $numlogs IIS logs older than $MaxDaysOld days old"
			}
		}
		$tempdata.Add([pscustomobject]@{
			Status = $stat
			Message = $msg
			Note    = "Path = $IISLogsPath"
		})
		#$totalDiskSize = $(Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID = 'C:'" | Select-Object -ExpandProperty Size) / 1MB
		$totalDiskSize = $(Get-WmiQueryResult -ClassName "Win32_LogicalDisk" -Query "DeviceID = 'C:'" -Params $ScriptParams | Select-Object -Expand Size) / 1MB
		$logSpaceUsed = [math]::Round($TotalSpaceMB / $totalDiskSize, 4)
		if (($logSpaceUsed * 100) -gt $MaxSpacePct) {
			$stat = $except
			$msg  = "IIS logs are using $TotalSpaceMB MB or $($logSpaceUsed * 100)`% of total capacity"
		} else {
			Write-Log -Message "IIS logs are using $TotalSpaceMB MB or $($logSpaceUsed * 100)`% of total capacity"
		}
		$tempdata.Add([pscustomobject]@{
			Status  = $stat
			Message = $msg
			Note    = "Capacity = $totalDiskSize , LogSpace = $logSpaceUsed"
		})
	}
	catch {
		$stat = 'ERROR'
		$msg = $_.Exception.Message -join ';'
	}
	finally {
		$([pscustomobject]@{
			TestName    = $TestName
			TestGroup   = $TestGroup
			Category    = $TestCategory
			TestData    = $tempdata
			Description = $Description
			Status      = $stat
			Message     = $msg
			RunTime     = $(Get-RunTime -BaseTime $startTime)
			Credential  = $(if($ScriptParams.Credential){$($ScriptParams.Credential).UserName} else { $env:USERNAME })
		})
	}
}
