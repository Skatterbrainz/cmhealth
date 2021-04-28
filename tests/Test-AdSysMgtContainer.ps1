function Test-AdSysMgtContainer {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Active Directory System Management Container",
		[parameter()][string] $TestGroup = "configuration",
		[parameter()][string] $Description = "Verify System Management container has been created with delegated permissions",
		[parameter()][hashtable] $ScriptParams
	)
	$startTime = (Get-Date)
	$stat = "PASS"
	$except = "FAIL"
	try {
		Write-Log -Message "Searching for AD container: System Management"
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
			$obj = Get-ADSIObject -Identity $colResults.Path.substring(7)
			$msg = "System Management container exists"
			Write-Log -Message "getting security permissions on container"
			$acls = dsacls.exe $obj.distinguishedName
			# foreach principal, strip off "Allow" prefix and "FULL CONTROL" suffix
			$full = $acls | Where-Object {$_ -match 'FULL CONTROL'} | ForEach-Object {$_.Substring(6,32).Trim()}
			$tempdata.Add(
				[pscustomobject]@{
					FullControlUsers = $($full -join ';')
				}
			)
		} else {
			$stat = $except
			$msg  = "System Management container was not found"
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
			RunTime     = $(Get-RunTime -BaseTime $startTime)
			Credential  = $(if($ScriptParams.Credential){$($ScriptParams.Credential).UserName} else { $env:USERNAME })
		})
	}
}