function Test-HostWindowsUpdates {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Test-HostWindowsUpdates",
		[parameter()][string] $TestGroup = "operation",
		[parameter()][string] $Description = "Description of this test",
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
			Write-Verbose "$($res.Count) updates are not installed"
			if ($ScriptParams.Remediate -eq $True) {
				$rsx  = Get-WindowsUpdate -ComputerName $ScriptParams.ComputerName -WindowsUpdate -AcceptAll -Install -RecurseCycle 3 -IgnoreReboot
				$stat = 'REMEDIATED'
				$msg  = "$($rsx.Count) updates were installed"
			}
			else {
				$stat = $except
				$msg  = "$($res.Count) Microsoft updates are waiting to be installed"
				$res | Foreach-Object { $tempdata.Add( @{KB=$($_.KB); Title=$($_.Title)} )}
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
		$endTime = (Get-Date)
		$runTime = $(New-TimeSpan -Start $startTime -End $endTime)
		$rt = "{0}h:{1}m:{2}s" -f $($runTime | Foreach-Object {$_.Hours,$_.Minutes,$_.Seconds})
		Write-Output $([pscustomobject]@{
			TestName    = $TestName
			TestGroup   = $TestGroup
			TestData    = $tempdata
			Description = $Description
			Status      = $stat
			Message     = $msg
			RunTime     = $rt
			Credential  = $(if($ScriptParams.Credential){$($ScriptParams.Credential).UserName} else { $env:USERNAME })
		})
	}
}
