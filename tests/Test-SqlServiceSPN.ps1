function Test-SqlServicesSPN {
	[CmdletBinding(SupportsShouldProcess = $True)]
	param (
		[parameter(Mandatory)][ValidateNotNullOrEmpty()][hashtable] $ScriptParams
	)
	Write-Verbose "test: sql service account spn"
	try {
		if ($spn = Get-DbaSpn -ComputerName $ScriptParams.ComputerName -ErrorAction SilentlyContinue) {
			$result = 'PASS'
		}
		else {
			if ($Remediate) {
				### TBD
				$result = 'REMEDIATED'
			}
			else {
				$result = 'FAIL'
			}
		}
	}
	catch {
		Write-Error $Error[0].Exception.Message
		$result = 'ERROR'
	}
	finally {
		$result 
	}
}
