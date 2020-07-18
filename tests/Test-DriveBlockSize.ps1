function Test-DriveBlockSize {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Test-DriveBlockSize",
		[parameter()][string] $TestGroup = "configuration",
		[parameter()][string] $Description = "Validate disk format block size",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat = "PASS"
		$msg  = "Success"
		$bsize = 65536
		Get-CimInstance "Win32_Volume" -ComputerName $ScriptParams.ComputerName -Filter "DriveType = 3" | 
			Where-Object {![string]::IsNullOrEmpty($_.DriveLetter)} | Foreach-Object {
				if ($_.BlockSize -eq $bsize) {$res = 'PASS'} else {$res = 'FAIL'}
				$tempdata.Add([pscustomobject]@{
					Computer = $ScriptParams.ComputerName
					Drive = $_.DriveLetter
					Result = $res 
				})
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
