function Test-NoSmsOnDriveFile {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Confirm NO_SMS_ON_DRIVE file exists",
		[parameter()][string] $TestGroup = "configuration",
		[parameter()][string] $Description = "Confirm NO_SMS_ON_DRIVE.SMS file resides on appropriate disks",
		[parameter()][string] $ComputerName = "localhost",
		[parameter()][bool] $Remediate = $False
	)
	try {
		$tempdata = $null # for detailed test output to return if needed
		$disks = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType=3" -ComputerName $ComputerName
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
					if ($Remediate) {
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
