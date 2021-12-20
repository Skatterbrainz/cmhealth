function Test-SqlDatabaseNameDefault {
	[CmdletBinding()]
	[OutputType()]
	param (
		[parameter()][string] $TestName = "Check if SQL DB name uses default format",
		[parameter()][string] $TestGroup = "configuration",
		[parameter()][string] $TestCategory = "SQL",
		[parameter()][string] $Description = "Check if site database name is using the CM_XXX format",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		$startTime = (Get-Date)
		#[int]$Setting = Get-CmHealthDefaultValue -KeySet "keygroup:keyname" -DataSet $CmHealthConfig
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat   = "PASS" # do not change this
		$except = "WARNING" # or "FAIL"
		$msg    = "No issues found" # do not change this either
		$dbname = $($CmhParams.Database)
		$dbtest = "CM_$($CmhParams.SiteCode)"
		if ($dbname -ne $dbtest) {
			$stat = $except
			$msg = "$dbname is not using the default naming format CM_(SiteCode)"
			Write-Log -Message $msg -Category $except
		} else {
			$msg = "$dbname is using the default naming format"
			Write-Log -Message $msg
		}
		$tempdata.Add(
			[pscustomobject]@{
				Status = $stat
				ComputerName = $reghost
				DatabaseName = $dbname
				Message = $msg
			}
		)
	}
	catch {
		$stat = 'ERROR'
		$msg = $_.Exception.Message -join ';'
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
