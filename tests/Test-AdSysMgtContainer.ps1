function Test-AdSysMgtContainer {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Test-AdSysMgtContainer",
		[parameter()][string] $TestGroup = "configuration",
		[parameter()][string] $Description = "Verify System Management container has been created with delegated permissions",
		[parameter()][hashtable] $ScriptParams
	)
	$startTime = (Get-Date)
	$stat = "PASS"
	$except = "FAIL"
	try {
		Write-Verbose "Searching for AD container: System Management"
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
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
				$stat = $except
				$msg  = "System Management container was not found"
			}
		}
	}
	catch {
		$stat = "ERROR"
		$msg  = $_.Exception.Message -join ';'
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