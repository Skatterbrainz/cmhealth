function Test-HostADKVersion {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Validate ADK Version",
		[parameter()][string] $TestGroup = "configuration",
		[parameter()][string] $Description = "Verify ADK version is supported",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		$startTime = (Get-Date)
		$versionTable = [pscustomobject]@{
			1906 = "10.0.17763,10.1.18362"
			1910 = "10.0.17763,10.1.18362"
			2002 = "10.1.18362,10.1.18362"
			2006 = "10.1.18362,10.1.19041"
			2010 = "10.1.18362,10.1.19041"
		}
		#[int]$Setting = Get-CmHealthDefaultValue -KeySet "keygroup:keyname" -DataSet $CmHealthConfig
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat   = "PASS" # do not change this
		$except = "WARNING" # or "FAIL"
		$msg    = "No issues found" # do not change this either
		$apps = Get-WmiQueryResult -ClassName "Win32_Product" -Query "Name = 'Windows PE x86 x64'" -Params $ScriptParams
		foreach ($app in $apps) {
			$name = $app.Name
			$version = $app.Version
			if ($pct -gt $MaxPctUsed) {
				$stat = $except
				$msg  = "One or more disks are low on free space"
			}
			$tempdata.Add(
				[pscustomobject]@{
					ADKPE   = $name
					Version = $version
					Used    = $used
					PctUsed = $pct
					MaxPct  = $MaxPctUsed
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