function Test-HostIESCDisabled {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Test-HostIESCDisabled",
		[parameter()][string] $TestGroup = "configuration",
		[parameter()][string] $Description = "Disable Internet Explorer Enhanced Security Configuration",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$AdminKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}"
		$UserKey  = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}"
		if ((Get-ItemProperty -Path $AdminKey -Name "IsInstalled" | Select-Object -ExpandProperty IsInstalled) -ne 0) {
			Write-Verbose "configuration is not compliant (is not disabled)"
			if ($Remediate -eq $True) {
				Set-ItemProperty -Path $AdminKey -Name "IsInstalled" -Value 0 -Force
				Set-ItemProperty -Path $UserKey -Name "IsInstalled" -Value 0 -Force
				Stop-Process -Name Explorer -Force
				$stat = "REMEDIATED"
				$msg  = "IE Enhanced Security Configuration (ESC) has been disabled."
			} else {
				$stat = "FAIL"
				$msg  = "IE Enhanced Security Configuration (IESC) is currently enabled"
			}
		} else {
			$stat = "PASS"
			$msg  = "IE Enhanced Security Configuration (ESC) is already disabled."
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
