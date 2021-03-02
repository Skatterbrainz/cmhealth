function Test-HostServices {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Windows Services Health",
		[parameter()][string] $TestGroup = "operation",
		[parameter()][string] $Description = "Verify auto-start services are running",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		$startTime = (Get-Date)
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat   = "PASS"
		$except = "WARNING"
		$msg    = "No issues found"
		$services = Get-WmiQueryResult -ClassName "Win32_Service" -Query "startmode = 'auto' and state != 'running'" -Params $ScriptParams
		if ($services.Count -gt 0) {
			$stat = $except
			$services | Foreach-Object {
				$tempdata.Add(
					[pscustomobject]@{
						Name = $_.Name
						StartMode = $_.StartMode
						State = $_.State
					}
				)
			}
			$msg = "$($services.Count) stopped services: $($services.Name -join ',')"
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
			RunTime     = $(Get-RunTime -BaseTime $startTime)
			Credential  = $(if($ScriptParams.Credential){$($ScriptParams.Credential).UserName} else { $env:USERNAME })
		})
	}
}
