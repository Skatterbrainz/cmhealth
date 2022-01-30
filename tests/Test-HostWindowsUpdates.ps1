function Test-HostWindowsUpdates {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Windows Update Compliance",
		[parameter()][string] $TestGroup = "operation",
		[parameter()][string] $TestCategory = "HOST",
		[parameter()][string] $Description = "Check if server is up to date on patches",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		$startTime = (Get-Date)
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat   = "PASS"
		$except = "WARNING"
		$msg    = "No issues found"
		$res = Get-WindowsUpdate -ComputerName $ScriptParams.ComputerName -WindowsUpdate -ErrorAction Stop
		if ($res.Count -gt 0) {
			Write-Log -Message "$($res.Count) updates are not installed"
			if ($ScriptParams.Remediate -eq $True) {
				$rsx  = Get-WindowsUpdate -ComputerName $ScriptParams.ComputerName -WindowsUpdate -AcceptAll -Install -RecurseCycle 3 -IgnoreReboot
				$stat = 'REMEDIATED'
				$msg  = "$($rsx.Count) updates were installed"
			}
			else {
				$stat = $except
				$msg  = "$($res.Count) Microsoft updates are waiting to be installed"
				$res | Foreach-Object {
					$tempdata.Add( 
						[pscustomobject]@{
							KB = $($_.KB)
							Title = $($_.Title)
						}
					)
				}
			}
		}
	}
	catch {
		$stat = 'ERROR'
		if ($_.CategoryInfo -match 'PermissionDenied') {
			$msg = "PsWindowsUpdate module dependency - does not support remote credentials"
		} else {
			$msg = $_.Exception.Message -join ';'
		}
	}
	finally {
		Set-CmhOutputData
	}
}
