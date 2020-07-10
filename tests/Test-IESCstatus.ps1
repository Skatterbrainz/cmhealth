function Test-IESCStatus {
	[CmdletBinding(SupportsShouldProcess=$True)]
	param (
		[parameter(Mandatory)][ValidateNotNullOrEmpty()][hashtable] $ScriptParams
	)
	Write-Verbose "test: iesc is disabled"
	try {
		$AdminKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}"
		$UserKey  = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}"
		if ((Get-ItemProperty -Path $AdminKey -Name "IsInstalled" | Select-Object -ExpandProperty IsInstalled) -ne 0) {
			Write-Verbose "configuration is not compliant (is not disabled)"
			if ($ScriptParams.Remediate) {
				Set-ItemProperty -Path $AdminKey -Name "IsInstalled" -Value 0 -Force
				Set-ItemProperty -Path $UserKey -Name "IsInstalled" -Value 0 -Force
				Stop-Process -Name Explorer -Force
				$result = "REMEDIATED"
			}
			else {
				$result = "FAIL"
			}
		}
		else {
			$result = "PASS"
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
