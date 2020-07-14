function Test-DriveBlockSize {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Check Disk Format Block Size",
		[parameter()][string] $TestGroup = "configuration",
		[parameter()][string] $Description = "Validate disk format block size",
		[parameter()][bool] $Remediate = $False,
		[parameter()][string] $SqlInstance = "localhost",
		[parameter()][string] $Database = ""
	)
	try {
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat = "PASS"
		$bsize = 65536
		Get-CimInstance "Win32_Volume" -ComputerName $ComputerName -Filter "DriveType = 3" | 
			Where-Object {![string]::IsNullOrEmpty($_.DriveLetter)} | Foreach-Object {
				if ($_.BlockSize -eq $bsize) {$res = 'PASS'} else {$res = 'FAIL'}
				[pscustomobject]@{
					Computer = $ScriptParams.ComputerName
					Drive = $_.DriveLetter
					Result = $res 
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
