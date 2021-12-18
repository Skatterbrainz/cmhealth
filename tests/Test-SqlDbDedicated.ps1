function Test-SqlDbDedicated {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Unsupported Databases",
		[parameter()][string] $TestGroup = "configuration",
		[parameter()][string] $TestCategory = "SQL",
		[parameter()][string] $Description = "Verify SQL Instance is dedicated to ConfigMgr site",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		$startTime = (Get-Date)
		$stat   = "PASS"
		$except = "WARNING"
		$msg    = "No issues found"
		$supported  = Get-CmHealthDefaultValue -KeySet "sqlserver:LicensedDatabases" -DataSet $CmHealthConfig
		Write-Log -Message "Supported Names: $($supported -join ',')"
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		if ($null -ne $ScriptParams.Credential) {
			$dbnames = Get-DbaDatabase -SqlInstance $ScriptParams.SqlInstance -SqlCredential $ScriptParams.Credential | Select-Object -ExpandProperty Name
		} else {
			$dbnames = Get-DbaDatabase -SqlInstance $ScriptParams.SqlInstance | Select-Object -ExpandProperty Name
		}
		$dblist1 = @()
		$dblist2 = @()
		$dbnames | ForEach-Object {
			Write-Log -Message "database name: $_"
			if (($_ -notmatch 'CM_') -and ($_ -notin $supported)) {
				Write-Log -Message "database is not supported: $($_)"
				$dblist1 += $($_).ToString()
				$isSupported = $False
			} else {
				Write-Log -Message "database is supported: $($_)"
				$dblist2 += $($_).ToString()
				$isSupported = $True
			}
			$tempdata.Add(
				[pscustomobject]@{
					SqlInstance = $($ScriptParams.SqlInstance)
					Database = $($_)
					Supported = $isSupported
				}
			)
		}
		if ($dblist1.Count -gt 0) {
			Write-Log -Message "$($dblist1.Count) unsupported names were found"
			$msg  = "$($dblist1.Count) databases are not supported by MEMCM SQL licensing"
			$stat = $except
		} else {
			Write-Log -Message "no unsupported names were found"
			$msg = "All databases are supported for MEMCM SQL licensing"
		}
	}
	catch {
		$msg = $_.Exception.Message -join ';'
		$stat = "ERROR"
	}
	finally {
		$([pscustomobject]@{
			TestName    = $TestName
			TestGroup   = $TestGroup
			Category    = $TestCategory
			TestData    = $tempdata
			Description = $Description
			Status      = $stat
			Message     = $msg
			RunTime     = $(Get-RunTime -BaseTime $startTime)
			Credential  = $(if($ScriptParams.Credential){$($ScriptParams.Credential).UserName} else { $env:USERNAME })
		})
	}
}
