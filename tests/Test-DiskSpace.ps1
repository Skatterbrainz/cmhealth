<#
.SYNOPSIS
	Validate Logical Disk Space
.DESCRIPTION
	Validate logical disk space usage
.PARAMETER ComputerName
	Name of computer or "" for local host
.PARAMETER Remediate
	Apply remediation changes if required
.EXAMPLE
	Test-LogicalDisks -Remediate
.NOTES
#>

function Test-LogicalDisks {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Logical Disk configurations",
		[parameter()][string] $TestGroup = "configuration",
		[parameter()][string] $Description = "",
		[parameter()][string] $ComputerName = "",
		[parameter()][bool] $Remediate = $False,
		[parameter()][int] $MaxPctUsed = 80
	)
	try {
		[System.Collections.Generic.List[PSObject]]$tempdata = @()
		if ([string]::IsNullOrEmpty($ComputerName)) {
			$disks = Get-CimInstance -ComputerName $ComputerName -ClassName Win32_LogicalDisk | Where-Object { $_.DriveType -eq 3 }
		}
		else {
			$disks = Get-CimInstance -ClassName Win32_LogicalDisk | Where-Object { $_.DriveType -eq 3 }
		}
		$stat = 'PASS'
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
		})
	}
}
