function Test-HostMemory {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Validate Host Memory",
		[parameter()][string] $TestGroup = "configuration",
		[parameter()][string] $Description = "Verify site system has at least minimum required memory",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat = "PASS"
		$msg  = "No issues found"
		$SystemInfo = Get-CimInstance -ClassName Win32_OperatingSystem -ComputerName $ScriptParams.ComputerName | Select-Object Name, TotalVisibleMemorySize, FreePhysicalMemory
		$TotalRAM = $SystemInfo.TotalVisibleMemorySize/1MB
		$FreeRAM = $SystemInfo.FreePhysicalMemory/1MB
		$UsedRAM = $TotalRAM - $FreeRAM
		$RAMPercentFree = ($FreeRAM / $TotalRAM) * 100
		$TotalRAM = [Math]::Round($TotalRAM, 2)
		$FreeRAM = [Math]::Round($FreeRAM, 2)
		$UsedRAM = [Math]::Round($UsedRAM, 2)
		$RAMPercentFree = [Math]::Round($RAMPercentFree, 2)
		if ($TotalRAM -lt 24GB) {
			$stat = "FAIL"
			$msg  = "24 GB is the minimum for CM with SQL Server instance on the same host"
		} elseif ($RAMPercentFree -lt 10) {
			$stat = "FAIL"
			$msg = "Less than 10 percent memory is available"
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
