[CmdletBinding()]
param (
	[parameter(Mandatory)][ValidateNotNullOrEmpty()][hashtable] $ScriptParams
)
Write-Verbose "test: disk space"
try {
	$result = @()
	$result += Get-CimInstance -ClassName "Win32_LogicalDisk" -ComputerName $ScriptParams.ComputerName | Foreach-Object {
		[pscustomobject]@{ 
			Drive  = $_.DeviceID
			Name   = $_.VolumeName
			SizeGB = [math]::Round(($_.Size / 1GB),2)
			FreeSpaceGB = [math]::Round(($_.FreeSpace / 1GB),2)
			Used   = [math]::Round($_.FreeSpace / $_.Size, 2)
		}
	}
}
catch {
	$result = $_.Exception.Message
}
finally {
	$result
}