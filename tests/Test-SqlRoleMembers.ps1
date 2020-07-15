function Test-SqlRoleMembers {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Check SQL DB Role",
		[parameter()][string] $TestGroup = "database",
		[parameter()][string] $Description = "Validate SQL database ownership role",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat = "PASS"
		$msg = "No issues found"
		$rmembers = @(Get-DbaDbRole -SqlInstance $ScriptParams.SqlInstance -Database $ScriptParams.Database -Role "db_owner" | Get-DbaDbRoleMember )
		if ($rmembers.Count -lt 1) {
			$stat = 'FAIL'
			$msg = "Incorrect or unassigned ownership role"
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
		})
	}
}