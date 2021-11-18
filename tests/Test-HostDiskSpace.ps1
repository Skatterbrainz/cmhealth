function Test-HostDiskSpace {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Disk Space Health",
		[parameter()][string] $TestGroup = "configuration",
		[parameter()][string] $TestCategory = "HOST",
		[parameter()][string] $Description = "Validate logical disk utilitization",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		$startTime = (Get-Date)
		[int]$MaxPctUsed = Get-CmHealthDefaultValue -KeySet "siteservers:DiskSpaceMaxPercent" -DataSet $CmHealthConfig
		Write-Log -Message "MaxPctUsed = $MaxPctUsed"

		[System.Collections.Generic.List[PSObject]]$tempdata = @()
		$stat   = "PASS"
		$except = "FAIL"
		$msg    = "No issues found"
		$disks  = Get-WmiQueryResult -ClassName "Win32_LogicalDisk" -Query "DriveType = 3" -Params $ScriptParams
		foreach ($disk in $disks) {
			$drv  = $disk.DeviceID
			$size = $disk.Size
			$free = $disk.FreeSpace
			$used = $size - $free
			$pct  = $([math]::Round($used / $size, 1)) * 100
			if ($pct -gt $MaxPctUsed) {
				$stat = $except
				$msg  = "One or more disks are low on free space"
			}
			$tempdata.Add(
				[pscustomobject]@{
					Drive   = $drv
					SizeGB  = [math]::Round($size / 1GB, 1)
					UsedGB  = [math]::Round($used / 1GB, 1)
					PctUsed = $pct
					MaxPct  = $MaxPctUsed
				}
			)
		} # foreach
	}
	catch {
		$stat = 'ERROR'
		$msg = $_.Exception.Message -join ';'
	}
	finally {
		Write-Output $([pscustomobject]@{
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
