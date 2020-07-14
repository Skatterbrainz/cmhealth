function Test-DiskSpace {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Disk Space",
		[parameter()][string] $TestGroup = "Operation"
	)
	Write-Verbose "test: disk space"
	try {
		[System.Collections.Generic.List[PSObject]]$tempdata = @()
		Get-CimInstance -ClassName "Win32_LogicalDisk" -ComputerName $cmhealthParams.ComputerName | Foreach-Object {
			if ($FreeSpaceGB -lt 10GB) {
				$stat = 'FAIL'
			} else {
				$stat = 'PASS'
			}
			$tempdata.Add([pscustomobject]@{ 
				Drive  = $_.DeviceID
				Name   = $_.VolumeName
				SizeGB = [math]::Round(($_.Size / 1GB),2)
				FreeSpaceGB = [math]::Round(($_.FreeSpace / 1GB),2)
				Used   = [math]::Round($_.FreeSpace / $_.Size, 2)
				Status = $stat
			})
		}
	}
	catch {
		$stat = 'ERROR'
		$msg  = $_.Exception.Message
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
