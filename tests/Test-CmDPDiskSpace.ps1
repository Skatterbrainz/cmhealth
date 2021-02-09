function Test-CMDPDiskSpace {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Test-CMDPDiskSpace",
		[parameter()][string] $TestGroup = "operation",
		[parameter()][string] $Description = "Check disk space status on all DPs",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		[int]$MaxPctUsed = Get-CmHealthDefaultValue -KeySet "siteservers:DiskSpaceMaxPercent" -DataSet $CmHealthConfig
		Write-Verbose "MaxPctUsed = $MaxPctUsed"

		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat = "PASS" # do not change this
		$msg  = "No issues found" # do not change this either
		Write-Verbose "requesting list of DP servers"
		$query = "select ServerName from v_DistributionPointInfo order by ServerName"
		[array]$dplist = Invoke-DbaQuery -SqlInstance $SqlInstance -Database $Database -Query $query
		Write-Verbose "$($dplist.Count) DP server names returned"
		foreach ($dp in $dplist) {
			if ($ScriptParams.ComputerName -ne $env:COMPUTERNAME) {
				$cs = New-CimSession -Credential $ScriptParams.Credential -Authentication Negotiate -ComputerName $dp
				$res = @(Get-CimInstance -CimSession $cs -ClassName Win32_LogicalDisk -Filter "DriveType = 3")
			} else {
				$res = @(Get-CimInstance -CimSession $cs -ClassName Win32_LogicalDisk -Filter "DriveType = 3")
			}
			if ($res.Count -gt 0) {
				foreach ($disk in $res) {
					$size = $disk.Size
					$free = $disk.FreeSpace
					$used = $size - $free
					$pct  = $([math]::Round($used / $size, 1)) * 100
					if ($pct -gt $MaxPctUsed) {
						$tempData.Add([pscustomobject]@{Computer=$(dp);Drive=$($disk.DeviceID);Size=$($size);Used=$pct})
						$stat = "WARNING"
					} else {
						$tempData.Add([pscustomobject]@{Computer=$(dp);Drive=$($disk.DeviceID);Size=$($size);Used=$pct})
					}
				} # foreach
				$msg = "$($tempData.Count) issues were found"
			}
		} # foreach
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
			Credential  = $(if($ScriptParams.Credential){$($ScriptParams.Credential).UserName} else { $env:USERNAME })
		})
	}
}
