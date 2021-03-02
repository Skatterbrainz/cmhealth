function Test-HostNetworkAccessibility {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Network Port Accessibility",
		[parameter()][string] $TestGroup = "configuration",
		[parameter()][string] $Description = "Test open TCP ports",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		$startTime = (Get-Date)
		# reference: https://docs.microsoft.com/en-us/mem/configmgr/core/plan-design/hierarchy/ports
		[string]$Setting = Get-CmHealthDefaultValue -KeySet "siteservers:tcpports" -DataSet $CmHealthConfig
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat   = "PASS" # do not change this
		$except = "FAIL"
		$msg    = "No issues found" # do not change this either
		$ErrorActionPreference = 'SilentlyContinue'
		$counter = 0; $good = 0; $bad = 0
		foreach ($port in ($setting -split ',')) {
			Write-Verbose "testing port: $port"
			try {
				$conn = New-Object System.Net.Sockets.TcpClient($(hostname),$port)
				$tempdata.Add(
					[pscustomobject]@{
						Hostname = $(hostname)
						Port     = $port
						Status   = $conn.Connected
					}
				)
				$good++
			}
			catch {
				$tempdata.Add(
					[pscustomobject]@{
						Hostname = $(hostname)
						Port     = $port
						Status   = "blocked"
					}
				)
				$bad++
			}
			$counter++
		}
		if ($bad -gt 0) {
			$stat = $except
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
			RunTime     = $(Get-RunTime -BaseTime $startTime)
			Credential  = $(if($ScriptParams.Credential){$($ScriptParams.Credential).UserName} else { $env:USERNAME })
		})
	}
}
