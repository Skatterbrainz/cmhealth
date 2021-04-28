function Test-HostDriveBlockSize {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Logical Drive Block Allocation",
		[parameter()][string] $TestGroup = "configuration",
		[parameter()][string] $Description = "Validate disk format block size",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		$startTime = (Get-Date)
		[int]$bsize = Get-CmHealthDefaultValue -KeySet "siteservers:DiskFormatBlockSize" -DataSet $CmHealthConfig
		Write-Log -Message "block size required = $bsize"
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat   = "PASS"
		$except = "WARNING"
		$msg    = "Success"
		$vols = Get-WmiQueryResult -ClassName "Win32_Volume" -Query "DriveType=3" -Params $ScriptParams
		foreach ($vol in $vols) {
			if ($vol.BlockSize -ne $bsize) {
				$res  = "FAIL"
				$stat = $except
				$msg  = "1 or more disks is not formatted to the recommended block size: $bsize bytes"
			} else {
				$res = 'PASS'
			}
			$tempdata.Add([pscustomobject]@{
				Computer  = $ScriptParams.ComputerName
				Drive     = $vol.DriveLetter
				BlockSize = $vol.BlockSize
				Required  = $bsize
				Result    = $res
			})
		} # foreach
	}
	catch {
		$stat = 'ERROR'
		$msg = $_.Exception.Message -join ';'
	}
	finally {
		if ($cs) { $cs.Close(); $cs = $null }
		Write-Output $([pscustomobject]@{
			TestName    = $TestName
			TestGroup   = $TestGroup
			TestData    = $tempdata
			Description = $Description
			Status      = $stat
			Message     = $msg
			RunTime     = $(Get-RunTime -BaseTime $startTime)
			Credential  = $(if($ScriptParams.Credential){$($ScriptParams.Credential).UserName} else { $env:USERNAME })
		})
	}
}
