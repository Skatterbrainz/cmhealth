function Test-HostDiskSpace {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Test-HostDiskSpace",
		[parameter()][string] $TestGroup = "configuration",
		[parameter()][string] $Description = "Validate logical disk utilitization",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		$startTime = (Get-Date)
		[int]$MaxPctUsed = Get-CmHealthDefaultValue -KeySet "siteservers:DiskSpaceMaxPercent" -DataSet $CmHealthConfig
		Write-Verbose "MaxPctUsed = $MaxPctUsed"

		[System.Collections.Generic.List[PSObject]]$tempdata = @()
		$stat   = "PASS"
		$except = "FAIL"
		$msg    = "No issues found"
		if ([string]::IsNullOrEmpty($ScriptParams.ComputerName)) {
			$disks = Get-CimInstance -ComputerName $ScriptParams.ComputerName -ClassName Win32_LogicalDisk -Credential $ScriptParams.Credential | Where-Object { $_.DriveType -eq 3 }
		}
		else {
			$disks = Get-CimInstance -ClassName Win32_LogicalDisk | Where-Object { $_.DriveType -eq 3 }
		}
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
					Size    = $size
					Used    = $used
					PctUsed = $pct
				}
			)
		} # foreach
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
