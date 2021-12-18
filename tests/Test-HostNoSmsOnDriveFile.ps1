function Test-HostNoSmsOnDriveFile {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "SMS Content Drive Exclusion",
		[parameter()][string] $TestGroup = "configuration",
		[parameter()][string] $TestCategory = "HOST",
		[parameter()][string] $Description = "Confirm NO_SMS_ON_DRIVE.SMS file resides on appropriate disks",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		$startTime = (Get-Date)
		$stat   = "PASS"
		$except = "WARNING"
		$msg    = "All non-CM disks are excluded"
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		if ($ScriptParams.Credential) {
			$cs = New-CimSession -Credential $ScriptParams.Credential -Authentication Negotiate -ComputerName $ScriptParams.ComputerName -ErrorAction Stop
			$disks = Get-CimInstance -CimSession $cs -ClassName Win32_LogicalDisk -Filter "DriveType=3" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty DeviceID
			foreach ($disk in $disks) {
				$fpth = "$($disk)\\NO_SMS_ON_DRIVE.sms"
				$clib = "$($disk)\\SMSPKGSIG"
				if (Get-CimInstance -Query "SELECT Name FROM CIM_Directory WHERE Name='$clib'" -CimSession $cs -ErrorAction SilentlyContinue) {
					$tempdata.Add([pscustomobject]@{
						Test    = $TestName
						Status  = "PASS"
						Message = "$($disk) appears to be a content library drive (not excluded)"
					})
				} else {
					if (Get-CimInstance -CimSession $cs -Query "SELECT Name FROM CIM_DataFile WHERE Name = '$fpth'" -ErrorAction SilentlyContinue) {
						$tempdata.Add([pscustomobject]@{
							Test    = $TestName
							Status  = "PASS"
							Message = "$($disk) is excluded from ConfigMgr content storage"
						})
					} else {
						if ($ScriptParams.Remediate -eq $True) {
							$tempdata.Add([pscustomobject]@{
								Test    = $TestName
								Status  = "REMEDIATED"
								Message = "$($disk) is now excluded from ConfigMgr content storage"
							})
						} else {
							$tempdata.Add([pscustomobject]@{
								Test    = $TestName
								Status  = $except
								Message = "$($_.DeviceID) is not excluded from ConfigMgr content storage"
							})
						}
					}
				}
			} # foreaach
		} else {
			$disks = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType=3" -ComputerName $ScriptParams.ComputerName -ErrorAction SilentlyContinue | Select-Object -ExpandProperty DeviceID
			foreach ($disk in $disks) {
				$fpth = "$($disk)\NO_SMS_ON_DRIVE.sms"
				$clib = "$($disk)\SMSPKGSIG"
				if (Test-Path $clib) {
					$tempdata.Add([pscustomobject]@{
						Test    = $TestName
						Status  = "PASS"
						Message = "$($disk) appears to be a content library drive (not excluded)"
					})
				} else {
					if ($ScriptParams.Remediate -eq $True) {
						$tempdata.Add([pscustomobject]@{
							Test    = $TestName
							Status  = "REMEDIATED"
							Message = "$($disk) is now excluded from ConfigMgr content storage"
						})
					} else {
						$tempdata.Add([pscustomobject]@{
							Test    = $TestName
							Status  = $except
							Message = "$($disk) is not excluded from ConfigMgr content storage"
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
		$([pscustomobject]@{
			TestName    = $TestName
			TestGroup   = $TestGroup
			Category    = $TestCategory
			TestData    = $tempdata
			Description = $Description
			Status      = $stat
			Message     = $msg
			RunTime     = $(Get-RunTime -BaseTime $startTime)
			Credential  = $(if($ScriptParams.Credential){$($ScriptParams.Credential).UserName} else { $env:USERNAME })
		})
	}
}
