function Test-HostIESCDisabled {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "IESC Feature Disabled",
		[parameter()][string] $TestGroup = "configuration",
		[parameter()][string] $TestCategory = "HOST",
		[parameter()][string] $Description = "Disable Internet Explorer Enhanced Security Configuration",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		$startTime = (Get-Date)
		$stat   = "PASS"
		$except = "FAIL"
		$msg    = "IE Enhanced Security Configuration (IESC) is already disabled"
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$AdminKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}"
		$UserKey  = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}"
		if ((Get-ItemProperty -Path $AdminKey -Name "IsInstalled" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty IsInstalled) -ne 0) {
			Write-Log -Message "configuration is not compliant (is not disabled)"
			if ($Remediate -eq $True) {
				Set-ItemProperty -Path $AdminKey -Name "IsInstalled" -Value 0 -Force
				Set-ItemProperty -Path $UserKey -Name "IsInstalled" -Value 0 -Force
				Stop-Process -Name Explorer -Force
				$stat = "REMEDIATED"
				$msg  = "IE Enhanced Security Configuration (ESC) has been disabled."
			} else {
				$stat = $except
				$msg  = "IE Enhanced Security Configuration (IESC) is currently enabled"
			}
		} else {
			Write-Log -Message "registry key was not found"
		}
	}
	catch {
		$stat = 'ERROR'
		$msg = $_.Exception.Message -join ';'
	}
	finally {
		Set-CmhOutputData
	}
}
