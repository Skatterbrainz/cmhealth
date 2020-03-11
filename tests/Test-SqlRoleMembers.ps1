[CmdletBinding()]
param (
	[parameter(Mandatory)][ValidateNotNullOrEmpty()][hashtable] $ScriptParams
)
try {
	$rmembers = @(Get-DbaDbRole -SqlInstance $ScriptParams.SqlInstance -Database $ScriptParams.Database -Role "db_owner" | Get-DbaDbRoleMember )
	if ($rmembers.Count -eq 1) {
		$result = 'PASS'
	}
	else {
		$result = 'FAIL'
	}
}
catch {
	Write-Error $_.Exception.Message
	$result = 'ERROR'
}
finally {
	$result
}