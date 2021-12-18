function Test-HostMemory {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Server Memory Allocation",
		[parameter()][string] $TestGroup = "configuration",
		[parameter()][string] $TestCategory = "HOST",
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
		$SystemInfo = Get-WmiQueryResult -ClassName "Win32_OperatingSystem" -Params $ScriptParams
		$TotalRAM = $SystemInfo.TotalVisibleMemorySize/1MB
		$FreeRAM  = $SystemInfo.FreePhysicalMemory/1MB
		$UsedRAM  = $TotalRAM - $FreeRAM
		$RAMPercentFree = ($FreeRAM / $TotalRAM) * 100
		$TotalRAM = [Math]::Round($TotalRAM, 2)
		$FreeRAM  = [Math]::Round($FreeRAM, 2)
		$UsedRAM  = [Math]::Round($UsedRAM, 2)
		$RAMPercentFree = [Math]::Round($RAMPercentFree, 2)
		Write-Log -Message "total memory = $TotalRAM"
		Write-Log -Message "minimum allowed memory = $MinMemory"
		if ($TotalRAM -lt $MinMemory) {
			$stat = $except
			$msg  = "$($TotalRam) GB is below the minimum recommended $MinMemory GB"
			$res | Foreach-Object {
				$tempdata.Add(
					[pscustomobject]@{
						Total    = $($TotalRam)
						Expected = $($MinMemory)
					}
				)
			}
		} elseif ($RAMPercentFree -lt 10) {
			$stat = $except
			$msg  = "Less than 10 percent memory is available"
			$res | Foreach-Object {
				$tempdata.Add(
					[pscustomobject]@{
						PctFree = $($RAMPercentFree)
						Expected = 10
					}
				)
			}
		} else {
			$res | Foreach-Object {
				$tempdata.Add(
					[pscustomobject]@{
						Total    = $($TotalRam)
						Expected = $($MinMemory)
					}
				)
			}
		}
	}
	catch {
		$stat = 'ERROR'
		$msg  = $_.Exception.Message -join ';'
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
