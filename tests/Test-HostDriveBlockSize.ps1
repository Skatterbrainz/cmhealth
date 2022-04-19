function Test-HostDriveBlockSize {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Logical Drive Block Allocation",
		[parameter()][string] $TestGroup = "configuration",
		[parameter()][string] $TestCategory = "HOST",
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
		[array]$vols = Get-WmiQueryResult -ClassName "Win32_Volume" -Query "DriveType=3" -Params $ScriptParams |
			Where-Object {$_.DriveLetter}
		foreach ($vol in $vols) {
			if ($vol.BlockSize -ne $bsize) {
				$res  = "FAIL"
				$stat = $except
				$msg  = "1 or more disks are not formatted to the recommended block size: $bsize bytes. "
				$msg += "Refer to https://docs.microsoft.com/en-us/mem/configmgr/core/plan-design/configs/site-size-performance-guidelines#example-disk-configurations"
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
		Set-CmhOutputData
	}
}
