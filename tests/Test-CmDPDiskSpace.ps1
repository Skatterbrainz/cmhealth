function Test-CMDPDiskSpace {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Test-CMDPDiskSpace",
		[parameter()][string] $TestGroup = "operation",
		[parameter()][string] $Description = "Check disk space status on all DPs",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		#[int]$Setting = Get-CmHealthDefaultValue -KeySet "keygroup:keyname" -DataSet $CmHealthConfig
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat = "PASS" # do not change this
		$msg  = "No issues found" # do not change this either
		if ($ScriptParams.ComputerName -ne $env:COMPUTERNAME) {
			if ($ScriptParams.Credential) {
				$cs = New-CimSession -Credential $ScriptParams.Credential -Authentication Negotiate -ComputerName $ScriptParams.ComputerName
				$res = @(Get-CimInstance -CimSession $cs -ClassName Win32_LogicalDisk -Filter "DriveType = 3")
			} else {
				$res = @(Get-CimInstance -CimSession $cs -ClassName Win32_LogicalDisk -Filter "DriveType = 3")
			}
		} else {
			$res = @(Get-CimInstance -CimSession $cs -ClassName Win32_LogicalDisk -Filter "DriveType = 3")
		}
		if ($res.Count -gt 0) {
			foreach ($disk in $res) {
				$used = $disk.Size - $disk.FreeSpace
				$pct  = $used / $disk.Size
				if ($pct -gt 0.9) {
					$tempData.Add(@{Computer=$($env:COMPUTERNAME);Drive=$($disk.DeviceID);Size=$($disk.Size);Used=$pct})
					$stat = "WARNING"
				}
			}
			$msg = "$($tempData.Count) issues were found"
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
			Credential  = $(if($ScriptParams.Credential){$($ScriptParams.Credential).UserName} else { $env:USERNAME })
		})
	}
}
