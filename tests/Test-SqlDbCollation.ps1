function Test-SqlDbCollation {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Test-SqlDbCollation",
		[parameter()][string] $TestGroup = "database",
		[parameter()][string] $Description = "Validate SQL database collation configruation",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		$startTime = (Get-Date)
		[string]$Collation = Get-CmHealthDefaultValue -KeySet "sqlserver:DefaultCollation" -DataSet $CmHealthConfig
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
	}
	catch {
		$stat = 'ERROR'
		$msg = $_.Exception.Message -join ';'
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
