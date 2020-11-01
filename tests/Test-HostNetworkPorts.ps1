function Test-HostNetworkPorts {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Test-HostNetworkPorts",
		[parameter()][string] $TestGroup = "configuration",
		[parameter()][string] $Description = "Test open TCP ports",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		# reference: https://docs.microsoft.com/en-us/mem/configmgr/core/plan-design/hierarchy/ports
		[string]$Setting = Get-CmHealthDefaultValue -KeySet "siteservers:tcpports" -DataSet $CmHealthConfig
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat = "PASS" # do not change this
		$msg  = "No issues found" # do not change this either
		$ErrorActionPreference = 'SilentlyContinue'
		$counter = 0; $good = 0; $bad = 0
		foreach ($port in ($setting -split ',')) {
			Write-Verbose "testing port: $port"
			try {
				$conn = New-Object System.Net.Sockets.TcpClient($(hostname),$port)
				$test = [pscustomobject]@{
					Hostname = $(hostname)
					Port     = $port 
					Status   = $conn.Connected
				}
				$good++
			}
			catch {
				$test = [pscustomobject]@{
					Hostname = $(hostname)
					Port     = $port 
					Status   = "blocked"
				}
				$bad++
			}
			$tempdata.Add($test)
			$counter++
		}
		if ($bad -eq $counter) {
			$stat = 'FAIL'
		} elseif ($bad -gt 0) {
			$stat = 'WARNING'
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
			Credential  = $(if($ScriptParams.Credential){$($ScriptParams.Credential).UserName} else { $env:USERNAME })
		})
	}
}
