function Test-HostDriveBlockSize {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Test-HostDriveBlockSize",
		[parameter()][string] $TestGroup = "configuration",
		[parameter()][string] $Description = "Validate disk format block size",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		$startTime = (Get-Date)
		[int]$bsize = Get-CmHealthDefaultValue -KeySet "siteservers:DiskFormatBlockSize" -DataSet $CmHealthConfig
		Write-Verbose "bsize = $bsize"
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat   = "PASS"
		$except = "FAIL"
		$msg    = "Success"
		if ($ScriptParams.ComputerName -ne $env:COMPUTERNAME) {
			if ($null -ne $ScriptParams.Credential) {
				$cs = New-CimSession -Credential $ScriptParams.Credential -Authentication Negotiate -ComputerName $ScriptParams.ComputerName
				$vols = Get-CimInstance "Win32_Volume" -CimSession $cs -Filter "DriveType = 3" | Where-Object {![string]::IsNullOrEmpty($_.DriveLetter)}
			} else {
				$vols = Get-CimInstance "Win32_Volume" -ComputerName $ScriptParams.ComputerName -Filter "DriveType = 3" | Where-Object {![string]::IsNullOrEmpty($_.DriveLetter)}
			}
		} else {
			$vols = Get-CimInstance "Win32_Volume" -Filter "DriveType = 3" | Where-Object {![string]::IsNullOrEmpty($_.DriveLetter)}
		}
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
		$endTime = (Get-Date)
		$runTime = $(New-TimeSpan -Start $startTime -End $endTime)
		$rt = "{0}h:{1}m:{2}s" -f $($runTime | Foreach-Object {$_.Hours,$_.Minutes,$_.Seconds})
		Write-Output $([pscustomobject]@{
			TestName    = $TestName
			TestGroup   = $TestGroup
			TestData    = $tempdata
			Description = $Description
			Status      = $stat
			Message     = $msg
			RunTime     = $rt
			Credential  = $(if($ScriptParams.Credential){$($ScriptParams.Credential).UserName} else { $env:USERNAME })
		})
	}
}
