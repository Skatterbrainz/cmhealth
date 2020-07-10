function Test-NoSmsOnDriveFile {
	[CmdletBinding()]
	param (
		[parameter(Mandatory)][ValidateNotNullOrEmpty()][hashtable] $ScriptParams
	)
	Write-Verbose "test: no_sms_on_drive.sms on each drive"
	try {
		$disks = Get-CimInstance -ClassName "Win32_LogicalDisk" -Filter "DriveType=3" -ComputerName $ScriptParams.ComputerName
		#$disks = Get-WmiObject -Class Win32_LogicalDisk -Filter "DriveType=3"
		$result = @()
		$disks | ForEach-Object {
			Write-Verbose "checking disk $($_.DeviceID) to see if distribution point shares are found"
			$fpth = (Join-Path -Path $_.DeviceID -ChildPath "NO_SMS_ON_DRIVE.SMS")
			$clib = (Join-Path -Path $_.DeviceID -ChildPath "SMSPKGSIG")
			if (Test-Path $clib) {
				Write-Output "PASS: $($_.DeviceID) appears to be a content library drive (not excluded)"
			}
			else {
				if (Test-Path $fpth) {
					$result += @{Drive = $_.DeviceID; Status = 'PASS'}
				}
				else {
					if ($ScriptParams.Remediate) {
						"added by remediation: $(Get-Date)" | Out-File -FilePath $fpth -Force
						$result += @{Drive = $_.DeviceID; Status = 'REMEDIATED'}
					}
					else {
						$result += @{Drive = $_.DeviceID; Status = 'FAIL'}
					}
				}
			}
		}
	}
	catch {
		Write-Error $Error[0].Exception.Message
		$result = 'ERROR'
	}
	finally {
		$result
	}
}
