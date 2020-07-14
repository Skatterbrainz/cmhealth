function Test-SqlServicesSPN {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Descriptive Name",
		[parameter()][string] $TestGroup = "configuration",
		[parameter()][string] $Description = "Description of this test",
		[parameter()][bool] $Remediate = $False,
		[parameter()][string] $SqlInstance = "",
		[parameter()][string] $Database = ""
	)
	Write-Verbose "test: sql service account spn"
	try {
		if ($spn = Get-DbaSpn -ComputerName $SqlInstance -ErrorAction SilentlyContinue) {
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
