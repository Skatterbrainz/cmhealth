function Test-HostDiskSpace {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Test-HostDiskSpace",
		[parameter()][string] $TestGroup = "configuration",
		[parameter()][string] $Description = "Validate logical disk utilitization",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		[int]$MaxPctUsed = Get-CmHealthDefaultValue -KeySet "siteservers:DiskSpaceMaxPercent" -DataSet $CmHealthConfig
		Write-Verbose "MaxPctUsed = $MaxPctUsed"

		[System.Collections.Generic.List[PSObject]]$tempdata = @()
		$stat = 'PASS'
		$msg = "No issues found"
		if ([string]::IsNullOrEmpty($ScriptParams.ComputerName)) {
			$disks = Get-CimInstance -ComputerName $ScriptParams.ComputerName -ClassName Win32_LogicalDisk -Credential $ScriptParams.Credential | Where-Object { $_.DriveType -eq 3 }
		}
		else {
			$disks = Get-CimInstance -ClassName Win32_LogicalDisk | Where-Object { $_.DriveType -eq 3 }
		}
		$disks | Foreach-Object {
			$drv  = $_.DeviceID 
			$size = $_.Size 
			$free = $_.FreeSpace
			$used = $size - $free
			$pct  = $([math]::Round($used / $size, 1)) * 100
			if ($pct -gt 80) {
				$tempdata.Add([pscustomobject]@{
					Test    = $TestName
					Status  = "FAIL"
					Message = "logical disk $drv is $pct`% full ($used of $size bytes)"
				})
			}
			else {
				$tempdata.Add([pscustomobject]@{
					Test    = $TestName
					Status  = "PASS"
					Message = "logical disk $drv is $pct`% full ($used of $size bytes)"
				})
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
			Credential  = $(if($ScriptParams.Credential){$($ScriptParams.Credential).UserName} else { $env:USERNAME })
		})
	}
}
