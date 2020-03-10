[CmdletBinding()]
param (
	[parameter(Mandatory)][ValidateNotNullOrEmpty()][hashtable] $ScriptParams
)
Write-Verbose "test: drive block size"
$bsize = 65536
Get-CimInstance "Win32_Volume" -ComputerName $ScriptParams.ComputerName -Filter "DriveType = 3" | 
	Where-Object {![string]::IsNullOrEmpty($_.DriveLetter)} | Foreach-Object {
		if ($_.BlockSize -eq $bsize) {$res = 'PASS'} else {$res = 'FAIL'}
		[pscustomobject]@{
			Drive = $_.DriveLetter
			Result = $res 
		}
	}