function Test-SqlDbCollation {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Test-SqlDbCollation",
		[parameter()][string] $TestGroup = "database",
		[parameter()][string] $Description = "Validate SQL database collation configruation",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		[string]$Collation = Get-CmHealthDefaultValue -KeySet "sqlserver:DefaultCollation" -DataSet $CmHealthConfig
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat = "PASS"
		$msg  = "No issues found"
		if ($ScriptParams.Credential) {
			$coll = Test-DbaDbCollation -SqlInstance $ScriptParams.SqlInstance -Database $ScriptParams.Database -SqlCredential $ScriptParams.Credential
		} else {
			$coll = Test-DbaDbCollation -SqlInstance $ScriptParams.SqlInstance -Database $ScriptParams.Database
		}
		if ($coll.DatabaseCollation -ne $Collation) {
			$stat = "FAIL"
			$msg  = "Collection is $($coll.DatabaseCollation) but should be $Collation"
		}
	}
	catch {
		$stat = 'ERROR'
		$msg = $_.Exception.Message -join ';'
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
