function Test-HostNoSmsOnDriveFile {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Test-HostNoSmsOnDriveFile",
		[parameter()][string] $TestGroup = "configuration",
		[parameter()][string] $Description = "Confirm NO_SMS_ON_DRIVE.SMS file resides on appropriate disks",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		$stat = "PASS"
		$msg  = "All non-CM disks are excluded"
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		if ($ScriptParams.Credential) {
			$cs = New-CimSession -Credential $ScriptParams.Credential -Authentication Negotiate -ComputerName $ScriptParams.ComputerName 
			$disks = Get-CimInstance -CimSession $cs -ClassName Win32_LogicalDisk -Filter "DriveType=3"
			$cs.Close()
			$cs = $null
		} else {
			$disks = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType=3" -ComputerName $ScriptParams.ComputerName
		}
		
		$disks | ForEach-Object {
			Write-Verbose "checking disk $($_.DeviceID) to see if distribution point shares are found"
			$fpth = (Join-Path -Path $_.DeviceID -ChildPath "NO_SMS_ON_DRIVE.SMS")
			$clib = (Join-Path -Path $_.DeviceID -ChildPath "SMSPKGSIG")
			if (Test-Path $clib) {
				$tempdata.Add([pscustomobject]@{
					Test    = $TestName
					Status  = "PASS"
					Message = "$($_.DeviceID) appears to be a content library drive (not excluded)"
				})
			} else {
				if (Test-Path $fpth) {
					$tempdata.Add([pscustomobject]@{
						Test = $TestName
						Status = "PASS"
						Message = "$($_.DeviceID) is excluded from ConfigMgr content storage"
					})
				} else {
					if ($ScriptParams.Remediate -eq $True) {
						$tempdata.Add([pscustomobject]@{
							Test = $TestName
							Status = "REMEDIATED"
							Message = "$($_.DeviceID) is now excluded from ConfigMgr content storage"
						})
					} else {
						$tempdata.Add([pscustomobject]@{
							Test = $TestName
							Status = "FAIL"
							Message = "$($_.DeviceID) is not excluded from ConfigMgr content storage"
						})
					}
				}
			}
		}
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
			Credential  = $(if($ScriptParams.Credential){$($ScriptParams.Credential).UserName} else { $env:USERNAME })
		})
	}
}
