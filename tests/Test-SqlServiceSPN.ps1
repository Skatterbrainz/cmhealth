function Test-SqlServiceSPN {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "SQL Service Principal Names (SPNs)",
		[parameter()][string] $TestGroup = "configuration",
		[parameter()][string] $TestCategory = "SQL",
		[parameter()][string] $Description = "Verify SQL instance Service Principal Name registration",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		$startTime = (Get-Date)
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat   = "PASS"
		$except = "WARNING"
		$msg    = "No issues found"
		$sqlserver = $ScriptParams.SqlInstance
		Write-Log -Message "instance name = $sqlserver"
		$domain    = $(Get-CimInstance -ClassName Win32_ComputerSystem | Select-Object -ExpandProperty Domain)
		Write-Log -Message "domain suffix = $domain"
		$fqdn      = "$($sqlserver)"
		$spn       = "MSSQLSvc/$($fqdn)*"
		Write-Log -Message "SPN name = $spn"
		$res       = $(SetSpn -T "$domain" -F -Q "$spn").Split("`n").Trim()
		if ($res -contains "No such SPN found.") {
			$stat = $except
			$msg  = "No MSSQLSvc SPNs have been registered for $fqdn"
		}
		foreach ($sp in $res) {
			if (![string]::IsNullOrEmpty($sp) -and (-not($sp.StartsWith("Checking") -or $sp.StartsWith("Existing SPN")))) {
				$tempdata.Add(
					[pscustomobject]@{
						HostName = $fqdn
						SPN = $sp
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
