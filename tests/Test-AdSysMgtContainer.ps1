function Test-AdSysMgtContainer {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "AD Container",
		[parameter()][string] $TestGroup = "configuration",
		[parameter()][string] $Description = "Verify System Management container has been created with delegated permissions",
		[parameter()][string] $ComputerName = "localhost",
		[parameter()][switch] $Remediate
	)
	try {
		Write-Verbose "Searching for AD container: System Management"
		$strFilter = "(&(objectCategory=Container)(Name=System Management))"
		$objDomain = New-Object System.DirectoryServices.DirectoryEntry
		$objSearcher = New-Object System.DirectoryServices.DirectorySearcher
		$objSearcher.SearchRoot = $objDomain
		$objSearcher.PageSize = 1000
		$objSearcher.Filter = $strFilter
		$objSearcher.SearchScope = "Subtree"
		$colProplist = "name"
		foreach ($i in $colProplist) { $objSearcher.PropertiesToLoad.Add($i) | Out-Null }
		$colResults = $objSearcher.FindAll()
		if ($colResults.Count -gt 0) {
			$stat = "PASS"
			$msg  = "System Management container verified"
		} else {
			if ($Remediate -eq $True) {
				if ([string]::IsNullOrEmpty($ComputerName)) {
					throw "Remediation requires the Site Server hostname to be provided (stop)"
				}
				$DomainDn = $([adsi]"").distinguishedName
				$ShortDn  = $([adsi]"").dc
				$SystemDn = "CN=System," + $DomainDn
				$SysContainer = [adsi]"LDAP://$SystemDn"
				$SysMgmtContainer = $SysContainer.Create("Container", "CN=System Management")
				$SysMgmtContainer.SetInfo()
				Write-Verbose "container has been created"
				Write-Verbose "assigning permissions to container"
				$path = "AD:\CN=System Management,$SystemDn"
				$acl = Get-Acl -Path $path
				$ace = New-Object Security.AccessControl.ActiveDirectoryAccessRule("$ShortDn\$ComputerName",'FullControl')
				$acl.AddAccessRule($ace)
				Set-Acl -Path $path -AclObject $acl
				$stat = "REMEDIATED"
				$msg  = "System Management container has been created"
			} else {
				$stat = "FAIL"
				$msg  = "System Management container was not found"
			}
		}
	}
	catch {
		$stat = "ERROR"
		$msg  = $_.Exception.Message -join ';'
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