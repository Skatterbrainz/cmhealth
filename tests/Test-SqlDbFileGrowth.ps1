[CmdletBinding()]
param (
	[parameter(Mandatory)][ValidateNotNull()][hashtable] $ScriptParams
)
Write-Verbose "test: sql db file autogrowth"
$files = Get-DbaDbFile -SqlInstance $ScriptParams.SqlInstance -Database $ScriptParams.Database