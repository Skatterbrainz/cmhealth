function Test-HostFirewallPorts {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Network Firewall Ports",
		[parameter()][string] $TestGroup = "configuration",
		[parameter()][string] $TestCategory = "HOST",
		[parameter()][string] $Description = "Test open firewall TCP ports",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		$startTime = (Get-Date)
		# reference: https://docs.microsoft.com/en-us/mem/configmgr/core/plan-design/hierarchy/ports
		[string]$Ports = Get-CmHealthDefaultValue -KeySet "siteservers:tcpports" -DataSet $CmHealthConfig
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat   = "PASS" # do not change this
		$except = "WARNING"
		$msg    = "No issues found" # do not change this either
		$ErrorActionPreference = 'SilentlyContinue'
		[array]$complist = @($ScriptParams.ComputerName)
		if ($ScriptParams.ComputerName -ne $ScriptParams.SqlInstance) {
			$complist += $ScriptParams.SqlInstance
		}
		foreach ($computer in $complist) {
			foreach ($port in $ports.split(',')) {
				if (Test-NetConnection -ComputerName $computer -Port $port -InformationLevel Quiet) {
					$pstat = 'open'
				} else {
					$pstat = 'blocked'
					$stat  = $except
					$msg   = "One or more TCP ports are blocked. Refer to https://docs.microsoft.com/en-us/mem/configmgr/core/plan-design/hierarchy/ports"
				}
				Write-Log -Message "computer=$computer, port=$port, status=$pstat"
				$tempdata.Add(
					[pscustomobject]@{
						ComputerName = $computer
						PortNumber   = $port
						Status       = $pstat
					}
				)
			}
		}
	}
	catch {
		$stat = 'ERROR'
		$msg = $_.Exception.Message -join ';'
	}
	finally {
		Set-CmhOutputData
	}
}
