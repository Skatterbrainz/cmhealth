function Test-SqlRoleMembers {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Check SQL DB Role",
		[parameter()][string] $TestGroup = "database",
		[parameter()][string] $Description = "Validate SQL database ownership role",
		[parameter()][bool] $Remediate = $False,
		[parameter()][string] $SqlInstance = "localhost",
		[parameter()][string] $Database = ""
	)
	try {
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat = "PASS"
		$rmembers = @(Get-DbaDbRole -SqlInstance $SqlInstance -Database $Database -Role "db_owner" | Get-DbaDbRoleMember )
		if ($rmembers.Count -ne 1) {
			$stat = 'FAIL'
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