#Databases on the CM SQL instance that are not supported by usage rights (if SQL is Standard)
function Test-SqlDbDedicated {
	[CmdletBinding()]
	param (
		[parameter(Mandatory)][ValidateNotNull()][hashtable] $ScriptParams
	)
	try {
		$result = 'PASS'
		$supported = ('master','tempdb','msdb','model','SUSDB','ReportServer','ReportServerTempDB')
		$dbnames = Get-DbaDatabase -SqlInstance $ScriptParams.SqlInstance | Select-Object -ExpandProperty Name
		$dbnames | ForEach-Object {
			if (-not (($_ -match 'CM_') -or ($_ -in $supported))) {
				$result = 'FAIL'
			}
		}
	}
	catch {
		Write-Error $_.Exception.Message 
		$result = 'ERROR'
	}
	finally {
		$result
	}
}
