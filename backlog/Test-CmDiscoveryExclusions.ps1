function Test-CmDiscoveryExclusions {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Discovery Methods with Exclusions",
		[parameter()][string] $TestGroup = "configuration",
		[parameter()][string] $Description = "Warn about exclusions and possible missing resources",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		$startTime = (Get-Date)
		#[int]$Setting = Get-CmHealthDefaultValue -KeySet "keygroup:keyname" -DataSet $CmHealthConfig
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat   = "PASS" # do not change this
		$except = "WARNING" # or "FAIL"
		$msg    = "No issues found" # do not change this either
		<#
		=======================================================
		|	COMMENT: DELETE THIS BLOCK WHEN FINISHED:
		|
		|	perform test and return result as an object...
		|		$stat = $except (no need to set "PASS" since it's the default)
		|		$msg = "custom message that N issues were found"
		|		add supporting data to $tempdata array if it helps output
		|		loop output into $tempdata.Add() array to return as TestData param in output
		=======================================================
		#>

		<#
		=======================================================
		COMMENT: EXAMPLE FOR SQL QUERY RELATED TESTS... DELETE THIS BLOCK IF NOT USED
		=======================================================

		$query = ""
		$res = Get-CmSqlQueryResult -Query $query -Params $ScriptParams
		if ($null -ne $res -and $res.Count -gt 0) {
			$stat = $except
			$msg  = "$($res.Count) items found"
			#$res | Foreach-Object {$tempdata.Add( [pscustomobject]@{Name=$_.Name} )}
		}
		=======================================================
		#>

		<#
		=======================================================
		COMMENT: EXAMPLE FOR WMI/CIM QUERY RELATED TESTS... DELETE THIS BLOCK IF NOT USED
		=======================================================

		$disks  = Get-WmiQueryResult -ClassName "Win32_LogicalDisk" -Query "DriveType = 3" -Params $ScriptParams
		foreach ($disk in $disks) {
			$drv  = $disk.DeviceID
			$size = $disk.Size
			$free = $disk.FreeSpace
			$used = $size - $free
			$pct  = $([math]::Round($used / $size, 1)) * 100
			if ($pct -gt $MaxPctUsed) {
				$stat = $except
				$msg  = "One or more disks are low on free space"
			}
			$tempdata.Add(
				[pscustomobject]@{
					Drive   = $drv
					Size    = $size
					Used    = $used
					PctUsed = $pct
					MaxPct  = $MaxPctUsed
				}
			)
		} # foreach
		=======================================================
		#>
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
