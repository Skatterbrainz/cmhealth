function Test-HostServices {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Windows Services Health",
		[parameter()][string] $TestGroup = "operation",
		[parameter()][string] $TestCategory = "HOST",
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
		Set-CmhOutputData
	}
}
