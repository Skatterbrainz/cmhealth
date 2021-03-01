function Test-HostDriverAutomationTool {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Check if Driver Automation Tool is installed",
		[parameter()][string] $TestGroup = "configuration",
		[parameter()][string] $Description = "Check if Driver Automation Tool is installed",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		$startTime = (Get-Date)
		[string]$latest = Get-CmHealthDefaultValue -KeySet "tools:DriverAutomationTool" -DataSet $CmHealthConfig
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat   = "PASS" # do not change this
		$except = "WARNING" # or "FAIL"
		$msg    = "No issues found" # do not change this either
		$res  = Get-WmiQueryResult -ClassName "Win32_Prodct" -Query "Name = 'Driver Automation Tool" -Params $ScriptParams
		foreach ($app in $res) {
			$appver = $app.Version
			if ($appver -ge $latest) {
				$msg = "latest version is installed: $latest"
			} else {
				$msg = "outdated version is installed: $appver"
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
		Write-Output $([pscustomobject]@{
			TestName    = $TestName
			TestGroup   = $TestGroup
			TestData    = $tempdata
			Description = $Description
			Status      = $stat
			Message     = $msg
			RunTime     = $(Get-RunTime -BaseTime $startTime)
			Credential  = $(if($ScriptParams.Credential){$($ScriptParams.Credential).UserName} else { $env:USERNAME })
		})
	}
}
