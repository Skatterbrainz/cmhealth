function Test-SqlRoleMembers {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "SQL Database Role Members",
		[parameter()][string] $TestGroup = "configuration",
		[parameter()][string] $Description = "Validate SQL database ownership role",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		$startTime = (Get-Date)
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat   = "PASS"
		$except = "WARNING"
		$msg    = "No issues found"
		if ($null -ne $ScriptParams.Credential) {
			$rmembers = @(Get-DbaDbRole -SqlInstance $ScriptParams.SqlInstance -Database $ScriptParams.Database -Role "db_owner" -SqlCredential $ScriptParams.Credential | Get-DbaDbRoleMember )
		} else {
			$rmembers = @(Get-DbaDbRole -SqlInstance $ScriptParams.SqlInstance -Database $ScriptParams.Database -Role "db_owner" | Get-DbaDbRoleMember )
		}
		if ($rmembers.Count -lt 1) {
			$stat = $except
			$msg = "Incorrect or unassigned ownership role"
		}
	}
	catch {
		$stat = 'ERROR'
		$msg = $_.Exception.Message -join ';'
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