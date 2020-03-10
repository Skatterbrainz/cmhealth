[CmdletBinding()]
param (
	[parameter(Mandatory)][ValidateNotNullOrEmpty()][hashtable] $ScriptParams
)
Write-Verbose "test: get file shares"
try {
	$pcname = $ScriptParams.ComputerName
	if ($pcname -match $env:COMPUTERNAME) {
		$shares = Get-CimInstance -ClassName "Win32_Share"
	}
	else {
		$shares = Get-CimInstance -ClassName "Win32_Share" -ComputerName $ScriptParams.ComputerName
	}
	$result = @()
	$shares | where {$_.Name -ne 'IPC$'} | % { 
		$spath = "\\$pcname\$($_.Name)"
		Write-Verbose "sharepath = $spath"
		$fpath = "\\$pcname\$($_.Path -replace ':','$')"
		Write-Verbose "filepath = $fpath"
		$perms1 = Get-CPermission -Path $spath
		$perms2 = Get-CPermission -Path $fpath
		$result += [pscustomobject]@{
			Name = $spath
			Path = $_.Path
			Description = $_.Description
			SharePermissions = $perms1
			FilePermissions  = $perms2
		}
	}	
}
catch {
	$result = 'ERROR'
	Write-Error $_.Exception.Message
}
finally {
	$result
}