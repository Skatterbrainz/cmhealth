function Test-HostDriverAutomationTool {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Check if Driver Automation Tool is installed",
		[parameter()][string] $TestGroup = "configuration",
		[parameter()][string] $TestCategory = "HOST",
		[parameter()][string] $Description = "Check if Driver Automation Tool is installed",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		$startTime = (Get-Date)
		[string]$latest = Get-CmHealthDefaultValue -KeySet "tools:DriverAutomationTool" -DataSet $CmHealthConfig
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat   = "WARNING" # assume not-installed is the baseline
		$except = "WARNING" # or "FAIL"
		$msg    = "Driver Automation Tool is not installed" # do not change this either
		$res  = Get-WmiQueryResult -ClassName "Win32_Product" -Query "Name = 'Driver Automation Tool'" -Params $ScriptParams
		foreach ($app in $res) {
			$appver = $app.Version
			if ($appver -ge $latest) {
				$msg = "latest version is installed: $latest"
				$stat = "PASS"
			} else {
				$msg = "outdated version is installed: $appver"
				$stat = $except
			}
			$tempdata.Add(
				[pscustomobject]@{
					ProductName = $app.Name
					Publisher   = $app.Vendor
					Version     = $app.Version
					Latest      = $latest
					ProductCode = $app.IdentifyingNumber
					InstallDate = $app.InstallDate
					InstallPath = $app.InstallLocation
				}
			)
		} # foreach
	}
	catch {
		$stat = 'ERROR'
		$msg = $_.Exception.Message -join ';'
	}
	finally {
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
