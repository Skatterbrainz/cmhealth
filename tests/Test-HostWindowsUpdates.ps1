function Test-HostWindowsUpdates {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Test-HostWindowsUpdates",
		[parameter()][string] $TestGroup = "operation",
		[parameter()][string] $Description = "Description of this test",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat = "PASS"
		$msg  = "No issues found"
		$res = Get-WindowsUpdate -ComputerName $ScriptParams.ComputerName -WindowsUpdate
		if ($res.Count -gt 0) {
			Write-Verbose "$($res.Count) updates are not installed"
			if ($ScriptParams.Remediate -eq $True) {
				$rsx = Get-WindowsUpdate -ComputerName $ScriptParams.ComputerName -WindowsUpdate -AcceptAll -Install -RecurseCycle 3 -IgnoreReboot
				$stat = 'REMEDIATED'
				$msg = "$($res.Count) updates were installed"
			}
			else {
				$stat = 'FAIL'
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
