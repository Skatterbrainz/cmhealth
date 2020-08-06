function Test-HostOperatingSystem {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Test-HostOperatingSystem",
		[parameter()][string] $TestGroup = "configuration",
		[parameter()][string] $Description = "Validate supported operating system for CM site system roles",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		$supported = @(Get-CmHealthDefaultValue -KeySet "siteservers:SupportedOperatingSystems" -DataSet $CmHealthConfig)
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat = "PASS"
		$msg  = "No issues found"
		if (![string]::IsNullOrEmpty($ScriptParams.ComputerName) -and $ScriptParams.ComputerName -ne $env:COMPUTERNAME) {
			if ($ScriptParams.Credential) {
				$cs = New-CimSession -Credential $ScriptParams.Credential -Authentication Negotiate -ComputerName $ScriptParams.ComputerName
				$osdata = Get-CimInstance -ClassName Win32_OperatingSystem -CimSession $cs | Select-Object Caption,Version,BuildNumber
			} else {
				$osdata = Get-CimInstance -ClassName Win32_OperatingSystem -ComputerName $ScriptParams.ComputerName | Select-Object Caption,Version,BuildNumber
			}
		} else {
			$osdata = Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object Caption,Version,BuildNumber
		}
		$osname = $osdata.Caption
		$osbuild = $osdata.BuildNumber
		$matched = (($supported | Foreach-Object {$osname -match $_}) -eq $True)
		if ($matched -ne $true) {
			$stat = "FAIL"
			$msg = "Unsupported operating system for site system roles: $osname $osbuild"
			$tempdata.Add("Supported: $($supported -join ',')")
		}
	}
	catch {
		$stat = 'ERROR'
		$msg = $_.Exception.Message -join ';'
	}
	finally {
		if ($cs) { $cs.Close(); $cs = $null }
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
