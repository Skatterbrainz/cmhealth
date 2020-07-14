#Databases on the CM SQL instance that are not supported by usage rights (if SQL is Standard)
function Test-SqlDbDedicated {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Dedicated SQL Instance",
		[parameter()][string] $TestGroup = "database",
		[parameter()][string] $Description = "Verify SQL Instance is dedicated to ConfigMgr site",
		[parameter()][bool] $Remediate = $False,
		[parameter()][string] $SqlInstance = "localhost"
	)
	try {
		$stat = 'PASS'
		$supported = ('master','tempdb','msdb','model','SUSDB','ReportServer','ReportServerTempDB')
		$dbnames = Get-DbaDatabase -SqlInstance $SqlInstance | Select-Object -ExpandProperty Name
		$dbnames | ForEach-Object {
			if (-not (($_ -match 'CM_') -or ($_ -in $supported))) {
				throw "Unsupported database: $($_)"
			}
		}
		$msg = "All databases are supported for ConfigMgr licensing"
	}
	catch {
		$msg = $_.Exception.Message -join ';'
		if ($msg -match 'Unsupported database') {
			$stat = "FAIL"
		} else {
			$stat = "ERROR"
		}
	}
	finally {
		Write-Output $([pscustomobject]@{
			TestName    = $TestName
			TestGroup   = $TestGroup
			TestData    = $tempdata
			Description = $Description
			Status      = $stat 
			Message     = $msg
		})
	}
}
