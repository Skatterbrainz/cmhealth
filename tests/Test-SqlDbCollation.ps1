function Test-SqlDbCollation {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "SQL Database Collation",
		[parameter()][string] $TestGroup = "configuration",
		[parameter()][string] $TestCategory = "SQL",
		[parameter()][string] $Description = "Validate SQL database collation configuration",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		$startTime = (Get-Date)
		[string]$Collation = Get-CmHealthDefaultValue -KeySet "sqlserver:DefaultCollation" -DataSet $CmHealthConfig
		Write-Log -Message "collation = $Collation"
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat   = "PASS"
		$except = "FAIL"
		$msg    = "No issues found"
		if ($null -ne $ScriptParams.Credential) {
			$coll = Test-DbaDbCollation -SqlInstance $ScriptParams.SqlInstance -Database $ScriptParams.Database -SqlCredential $ScriptParams.Credential
		} else {
			$coll = Test-DbaDbCollation -SqlInstance $ScriptParams.SqlInstance -Database $ScriptParams.Database
		}
		if ($coll.DatabaseCollation -ne $Collation) {
			$stat = $except
			$msg  = "Collection is $($coll.DatabaseCollation) but should be $Collation"
		}
		$tempdata.Add(
			[pscustomobject]@{
				Collation = $coll.DatabaseCollation
				Required  = $Collation
				Status    = $stat
			}
		)
	}
	catch {
		$stat = 'ERROR'
		$msg = $_.Exception.Message -join ';'
	}
	finally {
		Write-Output $([pscustomobject]@{
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
