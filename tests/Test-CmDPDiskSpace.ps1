function Test-CMDPDiskSpace {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Test-CMDPDiskSpace",
		[parameter()][string] $TestGroup = "operation",
		[parameter()][string] $Description = "Check disk space status on all DPs",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		$startTime = (Get-Date)
		[int]$MaxPctUsed = Get-CmHealthDefaultValue -KeySet "siteservers:DiskSpaceMaxPercent" -DataSet $CmHealthConfig
		Write-Verbose "MaxPctUsed = $MaxPctUsed"
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat = "PASS" # do not change this
		$except = "WARNING"
		$msg  = "No issues found" # do not change this either
		$issues = 0
		Write-Verbose "requesting list of DP servers"
		$query = "select ServerName from dbo.v_DistributionPointInfo order by ServerName"
		[array]$dplist = Invoke-DbaQuery -SqlInstance $SqlInstance -Database $Database -Query $query | Select-Object -ExpandProperty ServerName
		Write-Verbose "$($dplist.Count) DP server names returned"
		[string]$myFQDN=(Get-CimInstance Win32_ComputerSystem).DNSHostName+"."+(Get-CimInstance Win32_ComputerSystem).Domain
		[int]$index=1
		foreach ($dp in $dplist) {
			$res = $null; $cs = $null
			if ($dp -ne $myFQDN) {
				Write-Verbose "connecting to remote DP [$index of $($dplist.Count)]: $dp"
				$cs = New-CimSession -Credential $ScriptParams.Credential -Authentication Negotiate -ComputerName $dp -ErrorAction SilentlyContinue
				if ($null -ne $cs) {
					$res = @(Get-CimInstance -CimSession $cs -ClassName Win32_LogicalDisk -Filter "DriveType = 3" -ErrorAction SilentlyContinue)
				} else {
					$res = $null
				}
			} else {
				Write-Verbose "connecting to local DP [$index of $($dplist.Count)]: $dp"
				$res = @(Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType = 3")
			}
			if ($res.Count -gt 0) {
				foreach ($disk in $res) {
					$size = $disk.Size
					$free = $disk.FreeSpace
					$used = $size - $free
					$pct  = $([math]::Round($used / $size, 1)) * 100
					if ($pct -gt $MaxPctUsed) {
						$tempData.Add([pscustomobject]@{Computer=$($dp);Drive=$($disk.DeviceID);Size=$($size);Used=$pct})
						$stat = $except
						$issues++
					} else {
						$tempData.Add([pscustomobject]@{Computer=$($dp);Drive=$($disk.DeviceID);Size=$($size);Used=$pct})
					}
				} # foreach
				if ($issues -gt 0) { $msg = "$issues issues were found" }
			} else {
				Write-Warning "DP disk information is not available: $dp"
				$tempData.Add([pscustomobject]@{Computer=$($dp);Drive=$null;Size=$null;Used=$null})
			}
			$index++
		} # foreach
	}
	catch {
		$stat = 'ERROR'
		$msg = $_.Exception.Message -join ';'
	}
	finally {
		$rt = Get-RunTime -BaseTime $startTime
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
