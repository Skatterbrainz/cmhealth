function Test-CmSiteInstallAccountRoles {
	[CmdletBinding()]
	[OutputType()]
	param (
		[parameter()][string] $TestName = "ConfigMgr Install Account Roles and Permissions",
		[parameter()][string] $TestGroup = "configuration",
		[parameter()][string] $TestCategory = "CM",
		[parameter()][string] $Description = "Check if site install account has appropriate permissions/roles",
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
		[array]$sysadmins = Get-DbaServerRoleMember -SqlInstance $ScriptParams.SqlInstance -ServerRole "sysadmin" -ErrorAction Stop

		$query = "SELECT TOP (1) LogonName FROM dbo.vRBAC_Permissions WHERE CategoryID = 'SMS00ALL'"
		$res = Get-CmSqlQueryResult -Query $query -Params $ScriptParams
		$isLocalAdmin  = $False
		$isDomainAdmin = $False
		$isEntAdmin    = $False
		$isSchemaAdmin = $False
		$isSysAdmin    = $False
		if ($null -ne $res) {
			[string]$msg = @()
			$username = $res.LogonName
			$basename = $($username -split '\\')[1]
			if ($localAdmins.Name -contains $username) {
				Write-Log -Message "install account is a direct member of local Administrators group"
				$isLocalAdmin = $True
			} else {
				Write-Log -Message "install account is not a member of local Administrators group"
				$stat = $except
				$msg += "install account is not a local Administrators group member"
			}
			if ($sysadmins -contains $username) {
				Write-Log -Message "install account is a direct member of SQL sysadmins group"
				$isSysAdmin = $True
			}
			$dagroup = Get-ADSIGroupMember -Identity "Domain Admins" | Select-Object -expand name
			if ($dagroup -contains $basename) {
				Write-Log -Message "install account is a direct member of Domain Admins group"
				$isDomainAdmin = $True
				$stat = $except
				$msg += "install account is in Domain Admins group"
			}
			$eagroup = Get-ADSIGroupMember -Identity "Enterprise Admins" | Select-Object -expand name
			if ($eagroup -contains $basename) {
				Write-Log -Message "install account is a direct member of Enterprise Admins group"
				$isEntAdmin = $True
				$stat = $except
				$msg += "install account is in Enterprise Admins group"
			}
			$sagroup = Get-ADSIGroupMember -Identity "Schema Admins" | Select-Object -expand name
			if ($sagroup -contains $basename) {
				Write-Log -Message "install account is a direct member of Schema Admins group"
				$isSchemaAdmin = $True
				$stat = $except
				$msg += "install account is in Schema Admins group"
			}
			$tempdata.Add([pscustomobject]@{
				InstallAccount = $username
				IsLocalAdmin   = $isLocalAdmin
				IsDomainAdmin  = $isDomainAdmin
				IsEnterpriseAdmin = $isEntAdmin
				IsSchemaAdmin  = $isSchemaAdmin
				IsSqlSysAdmin  = $isSysAdmin
			})
		} else {
			Write-Warning "unable to query site installation account from database"
		}
	}
	catch {
		$stat = 'ERROR'
		$msg += $_.Exception.Message -join ';'
	}
	finally {
		Set-CmhOutputData
	}
}
