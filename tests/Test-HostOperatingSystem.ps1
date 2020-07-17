function Test-HostOperatingSystem {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Validate Host Operating System",
		[parameter()][string] $TestGroup = "configuration",
		[parameter()][string] $Description = "Validate supported operating system for CM site system roles",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat = "PASS"
		$msg  = "No issues found"
		$supported = @('Windows Server 2016','Windows Server 2019','Windows 10 Enterprise')
		$osdata = Get-CimInstance -ClassName Win32_OperatingSystem -ComputerName $ScriptParams.ComputerName 
		$osname = $osdata.Caption
		$osbuild = $osdata.BuildNumber
		if (($supported | Foreach-Object { $osname -match $_ }) -ne $true) {
			$stat = "FAIL"
			$msg = "Unsupported operating system for site system roles: $osname $osbuild"
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
