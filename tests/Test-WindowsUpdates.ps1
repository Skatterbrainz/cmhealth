function Test-WindowsUpdates {
	[CmdletBinding()]
	param (
		[parameter(Mandatory)][hashtable] $ScriptParams
	)
	Write-Verbose "test: missing windows updates"
	try {
		$res = Get-WindowsUpdate -ComputerName $ScriptParams.ComputerName -WindowsUpdate
		if ($res.Count -gt 0) {
			Write-Verbose "$($res.Count) updates are not installed"
			if ($ScriptParams.Remediate -eq $True) {
				$rsx = Get-WindowsUpdate -ComputerName $ScriptParams.ComputerName -WindowsUpdate -AcceptAll -Install -RecurseCycle 3 -IgnoreReboot
				$result = 'REMEDIATED'
			}
			else {
				$result = 'FAIL'
			}
		}
		else {
			$result = 'PASS'
		}
	}
	catch {
		$result = 'ERROR'
		Write-Error $_.Exception.Message
	}
	finally {
		$result
	}
}
