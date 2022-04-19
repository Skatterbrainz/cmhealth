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
		$IISLogsPath = Join-Path $LogsBase -ChildPath "W3SVC1"
		#$IISLogsDrive = Split-Path $IISLogsPath -Qualifier
		
		#$disksize = $(Get-WmiQueryResult -ClassName 'Win32_LogicalDisk' -Filter "DeviceID = '$IISLogsDrive'" | Select-Object -ExpandProperty Size
		#$disksizeMB = $disksize / 1MB
		#$disksizeGB = $disksize / 1GB
		
		$logs = Get-ChildItem -Path $IISLogsPath -Filter "*.log"
		#$logspace = $logs | Measure-Object -Property Length -Sum | Select-Object -ExpandProperty Sum
		#$logspaceGB = $logspace / 1GB

		$OldLogs = @($logs | Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-$MaxDaysOld) })

		if ($OldLogs.Count -gt 0) {
			Write-Log -Message "$($oldLogs.Count) older log files were found"
			$stat = $except
			$msg  = "$($OldLogs.Count) of $numlogs IIS logs older than $MaxDaysOld days old"
		}
		$tempdata.Add([pscustomobject]@{
			Status  = $stat
			Message = $msg
			Note    = "Path = $IISLogsPath"
		})
	}
	catch {
		$stat = 'ERROR'
		$msg = $_.Exception.Message -join ';'
	}
	finally {
		Set-CmhOutputData
	}
}
