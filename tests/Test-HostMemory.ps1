function Test-HostMemory {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Test-HostMemory",
		[parameter()][string] $TestGroup = "configuration",
		[parameter()][string] $Description = "Verify site system has at least minimum required memory",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		$startTime = (Get-Date)
		[int]$MinMemory = Get-CmHealthDefaultValue -KeySet "siteservers:MinimumMemoryGB" -DataSet $CmHealthConfig
		$MinMem = $($MinMemory * 1GB)
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat   = "PASS"
		$except = "WARNING"
		$msg    = "No issues found"
		if ($ScriptParams.Credential) {
			$cs = New-CimSession -ComputerName $ScriptParams.ComputerName -Authentication Negotiate -Credential $ScriptParams.Credential
			$SystemInfo = Get-CimInstance -CimSession $cs -ClassName Win32_OperatingSystem -ErrorAction SilentlyContinue | Select-Object Name, TotalVisibleMemorySize, FreePhysicalMemory
			$cs.Close()
		} else {
			$SystemInfo = Get-CimInstance -ClassName Win32_OperatingSystem -ComputerName $ScriptParams.ComputerName -ErrorAction SilentlyContinue | Select-Object Name, TotalVisibleMemorySize, FreePhysicalMemory
		}
		$TotalRAM = $SystemInfo.TotalVisibleMemorySize/1MB
		$FreeRAM  = $SystemInfo.FreePhysicalMemory/1MB
		$UsedRAM  = $TotalRAM - $FreeRAM
		$RAMPercentFree = ($FreeRAM / $TotalRAM) * 100
		$TotalRAM = [Math]::Round($TotalRAM, 2)
		$FreeRAM  = [Math]::Round($FreeRAM, 2)
		$UsedRAM  = [Math]::Round($UsedRAM, 2)
		$RAMPercentFree = [Math]::Round($RAMPercentFree, 2)
		if ($TotalRAM -lt $MinMem) {
			$stat = $except
			$msg  = "$($TotalRam) GB is below the minimum recommended $MinMemory GB"
			$res | Foreach-Object {$tempdata.Add("Total=$($TotalRam),Expected=$($MinMemory)")}
		} elseif ($RAMPercentFree -lt 10) {
			$stat = $except
			$msg  = "Less than 10 percent memory is available"
			$res | Foreach-Object {$tempdata.Add("PctFree=$($RAMPercentFree),Expected=10")}
		}
	}
	catch {
		$stat = 'ERROR'
		$msg  = $_.Exception.Message -join ';'
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
			Credential  = $(if($ScriptParams.Credential){$($ScriptParams.Credential).UserName} else { $env:USERNAME })
		})
	}
}
