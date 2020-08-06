function Test-SqlDbDedicated {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Test-SqlDbDedicated",
		[parameter()][string] $TestGroup = "database",
		[parameter()][string] $Description = "Verify SQL Instance is dedicated to ConfigMgr site",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		$stat = 'PASS'
		$msg  = "No issues found"
		$supported = @('master','tempdb','msdb','model','SUSDB','ReportServer','ReportServerTempDB')
		if ($ScriptParams.Credential) {
			$dbnames = Get-DbaDatabase -SqlInstance $ScriptParams.SqlInstance -SqlCredential $ScriptParams.Credential | Select-Object -ExpandProperty Name
		} else { 
			$dbnames = Get-DbaDatabase -SqlInstance $ScriptParams.SqlInstance | Select-Object -ExpandProperty Name
		}
		$dblist = @()
		$dbnames | ForEach-Object {
			if (-not (($_ -match 'CM_') -or ($_ -in $supported))) {
				$dblist += $_
			}
		}
		if ($dblist.Count -gt 0) {
			$stat = "FAIL"
			$msg  = "Databases found which are not supported by MEMCM SQL licensing"
			$tempdata.Add($dblist)
		} else {
			$msg = "All databases are supported for MEMCM SQL licensing"
		}
	}
	catch {
		$msg = $_.Exception.Message -join ';'
		$stat = "ERROR"
	}
	finally {
		Write-Output $([pscustomobject]@{
			TestName    = $TestName
			TestGroup   = $TestGroup
			TestData    = $tempdata
			Description = $Description
			Status      = $stat 
			Message     = $msg
			Credential  = $(if($ScriptParams.Credential){$($ScriptParams.Credential).UserName} else { $env:USERNAME })
		})
	}
}
