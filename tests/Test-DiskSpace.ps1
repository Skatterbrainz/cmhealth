function Test-DiskSpace {
	[CmdletBinding()]
	param (
		[parameter(Mandatory)][ValidateNotNullOrEmpty()][hashtable] $ScriptParams
	)
	Write-Verbose "test: disk space"
	try {
		$result = @()
		$result += Get-CimInstance -ClassName "Win32_LogicalDisk" -ComputerName $ScriptParams.ComputerName | Foreach-Object {
			if ($FreeSpaceGB -lt 10GB) {
				$stat = 'FAIL'
			} else {
				$stat = 'PASS'
			}
			[pscustomobject]@{ 
				Drive  = $_.DeviceID
				Name   = $_.VolumeName
				SizeGB = [math]::Round(($_.Size / 1GB),2)
				FreeSpaceGB = [math]::Round(($_.FreeSpace / 1GB),2)
				Used   = [math]::Round($_.FreeSpace / $_.Size, 2)
				Status = $stat
			}
		}
	}
	catch {
		$result = $_.Exception.Message
	}
	finally {
		$result
	}
}
