function Test-SqlDbDedicated {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Unsupported Databases",
		[parameter()][string] $TestGroup = "configuration",
		[parameter()][string] $Description = "Verify SQL Instance is dedicated to ConfigMgr site",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		$startTime = (Get-Date)
		$stat   = "PASS"
		$except = "WARNING"
		$msg    = "No issues found"
		$supported  = Get-CmHealthDefaultValue -KeySet "sqlserver:LicensedDatabases" -DataSet $CmHealthConfig
		Write-Verbose "Supported Names: $($supported -join ',')"
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		if ($null -ne $ScriptParams.Credential) {
			$dbnames = Get-DbaDatabase -SqlInstance $ScriptParams.SqlInstance -SqlCredential $ScriptParams.Credential | Select-Object -ExpandProperty Name
		} else {
			$dbnames = Get-DbaDatabase -SqlInstance $ScriptParams.SqlInstance | Select-Object -ExpandProperty Name
		}
		$dblist1 = @()
		$dblist2 = @()
		$dbnames | ForEach-Object {
			Write-Verbose "database name: $_"
			if (($_ -notmatch 'CM_') -and ($_ -notin $supported)) {
				Write-Verbose "database is not supported: $($_)"
				$dblist1 += $($_).ToString()
			} else {
				Write-Verbase "database is supported: $($_)"
				$dblist2 += $($_).ToString()
			}
		}
		if ($dblist1.Count -gt 0) {
			Write-Verbose "$($dblist1.Count) unsupported names were found"
			$stat = $except
			$msg  = "$($dblist1.Count) databases are not supported by MEMCM SQL licensing"
			$dblist1 | Foreach-Object {
				$tempdata.Add(
					[pscustomobject]@{
						Unsupported = $($_).ToString()
					}
				)
			}
		} else {
			Write-Verbose "no unsupported names were found"
			if ($dblist2.Count -gt 0) {
				$tempdata.Add("$($dblist2 -join ',')")
			} else {
				$tempdata.Add("$($supported -join ',')")
			}
			$msg = "All databases are supported for MEMCM SQL licensing"
		}
	}
	catch {
		$msg = $_.Exception.Message -join ';'
		$stat = "ERROR"
	}
	finally {
		$rt = Get-RunTime -BaseTime $startTime
		Write-Output $([pscustomobject]@{
			TestName    = $TestName
			TestGroup   = $TestGroup
			TestData    = $tempdata
			Description = $Description
			Status      = $stat
			Message     = $msg
			RunTime     = $rt
			Credential  = $(if($ScriptParams.Credential){$($ScriptParams.Credential).UserName} else { $env:USERNAME })
		})
	}
}
