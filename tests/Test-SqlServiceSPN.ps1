function Test-SqlServiceSPN {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "SQL Service Principal Names (SPNs)",
		[parameter()][string] $TestGroup = "configuration",
		[parameter()][string] $Description = "Verify SQL instance Service Principal Name registration",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		$startTime = (Get-Date)
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat   = "PASS"
		$except = "FAIL"
		$msg    = "No issues found"
		$sqlserver = $ScriptParams.SqlInstance
		Write-Verbose "instance name = $sqlserver"
		$domain    = $(Get-CimInstance -ClassName Win32_ComputerSystem | Select-Object -ExpandProperty Domain)
		Write-Verbose "domain suffix = $domain"
		$fqdn      = "$($sqlserver).$($domain)"
		$spn       = "MSSQLSvc/$($fqdn)*"
		Write-Verbose "SPN name = $spn"
		$res       = $(SetSpn -T "$domain" -F -Q "$spn").Split("`n").Trim()
		if ($res -contains "No such SPN found.") {
			$stat = $except
			$msg  = "No MSSQLSvc SPNs have been registered for $fqdn"
		} else {
			foreach ($sp in $res) {
				if (![string]::IsNullOrEmpty($sp) -and (-not($sp.StartsWith("Checking") -or $sp.StartsWith("Existing SPN")))) {
					$tempdata.Add(
						[pscustomobject]@{
							SPN = $sp
						}
					)
				}
			}
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
