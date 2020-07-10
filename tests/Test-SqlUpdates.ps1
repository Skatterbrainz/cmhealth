function Test-SqlUpdates {
	[CmdletBinding()]
	param (
		[parameter(Mandatory)][ValidateNotNullOrEmpty()][hashtable] $ScriptParams
	)
	Write-Verbose "test: sql instance updates"
	try {
		$res = Test-DbaBuild -Latest -SqlInstance $ScriptParams.SqlInstance
		if ($res.Compliant -eq $True) { $result = 'PASS' } else { $result = 'FAIL' }
	}
	catch {
		$result = 'ERROR'
	}
	finally {
		$result 
	}
}
