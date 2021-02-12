function Test-CmInstallAccountRoles {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Test-CmInstallAccountRoles",
		[parameter()][string] $TestGroup = "configuration",
		[parameter()][string] $Description = "Check if site install account has more permissions/roles than it needs",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		$startTime = (Get-Date)
		#[int]$Setting = Get-CmHealthDefaultValue -KeySet "keygroup:keyname" -DataSet $CmHealthConfig
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat   = "PASS" # do not change this
		$except = "WARNING" # or "FAIL"
		$msg    = "No issues found" # do not change this either
		[array]$localAdmins = Get-LocalGroupMember -Group "Administrators" -ErrorAction Stop
		[array]$sysadmins = Get-DbaServerRoleMember -SqlInstance $server -ServerRole "sysadmin" -ErrorAction Stop

		$query = "SELECT TOP (1) LogonName FROM dbo.vRBAC_Permissions WHERE CategoryID = 'SMS00ALL'"
		$res = Get-CmSqlQueryResult -Query $query -Params $ScriptParams
		if ($null -ne $res) {
			$username = $res.LogonName
			$basename = $($username -split '\\')[1]
			if ($localAdmins.Name -contains $username) {
				Write-Verbose "install account is a direct member of local administrators group"
				$isLocalAdmin = $True
			}
			if ($sysadmins -contains $username) {
				Write-Verbose "install account is a direct member of SQL sysadmins group"
				$isSysAdmin = $True
			}
			$dagroup = Get-ADSIGroupMember -Identity "Domain Admins" | Select-Object -expand name
			if ($dagroup -contains $basename) {
				Write-Verbose "install account is a direct member of Domain Admins group"
				$isDomainAdmin = $True
				$stat = $except
				$msg = "install account has more permissions than it may require"
			}
			$tempdata.Add([pscustomobject]@{
				InstallAccount = $username
				IsLocalAdmin   = $isLocalAdmin
				IsDomainAdmin  = $isDomainAdmin
				IsSqlSysAdmin  = $isSysAdmin
			})
		} else {
			Write-Warning "unable to query site installation account from database"
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
