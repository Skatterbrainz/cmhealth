function Test-HostOperatingSystem {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Supported Operating System",
		[parameter()][string] $TestGroup = "configuration",
		[parameter()][string] $TestCategory = "HOST",
		[parameter()][string] $Description = "Validate supported operating system for CM site system roles",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		$startTime = (Get-Date)
		$supported = @(Get-CmHealthDefaultValue -KeySet "siteservers:SupportedOperatingSystems" -DataSet $CmHealthConfig)
		Write-Log -Message "Supported OS list = $($supported -join ',')"
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat    = "PASS"
		$except  = "FAIL"
		$msg     = "No issues found"
		$osdata  = Get-WmiQueryResult -ClassName "Win32_OperatingSystem" -Params $ScriptParams
		$osname  = $osdata.Caption
		$osbuild = $osdata.BuildNumber
		$matched = (($supported | Foreach-Object {$osname -match $_}) -eq $True)
		if ($matched -ne $true) {
			$stat = $except
			$msg = "Unsupported operating system for site system roles: $osname $osbuild"
			$tempdata.Add("Supported: $($supported -join ',')")
		} else {
			$msg = "$($osdata.Caption) $($osdata.BuildNumber)"
		}
	}
	catch {
		$stat = 'ERROR'
		$msg = $_.Exception.Message -join ';'
	}
	finally {
		if ($cs) { $cs.Close(); $cs = $null }
		Set-CmhOutputData
	}
}
