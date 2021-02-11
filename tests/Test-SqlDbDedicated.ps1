function Test-SqlDbDedicated {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Test-SqlDbDedicated",
		[parameter()][string] $TestGroup = "database",
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
			if (-not (($_ -match 'CM_') -or ($_ -in $supported))) {
				$dblist1 += $_
			} else {
				$dblist2 += $_
			}
		}
		if ($dblist1.Count -gt 0) {
			Write-Verbose "unsupported names were found"
			$stat = $except
			$msg  = "Databases found which are not supported by MEMCM SQL licensing"
			$tempdata.Add("$($dblist1 -join ',')")
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
		$endTime = (Get-Date)
		$runTime = $(New-TimeSpan -Start $startTime -End $endTime)
		$rt = "{0}h:{1}m:{2}s" -f $($runTime | Foreach-Object {$_.Hours,$_.Minutes,$_.Seconds})
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
