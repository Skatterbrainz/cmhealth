function Test-AdSchemaExtension {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Active Directory Schema Extended",
		[parameter()][string] $TestGroup = "configuration",
		[parameter()][string] $Description = "Verify AD schema extensions have been installed",
		[parameter()][hashtable] $ScriptParams
	)
	$startTime = (Get-Date)
	$stat = "PASS"
	$except = "FAIL"
	try {
		$tempdata = $null
		Write-Verbose "Verifying for AD Schema extension"
		$strFilter = "(&(objectClass=mSSMSSite)(Name=*))"
		$objDomain = New-Object System.DirectoryServices.DirectoryEntry
		$objSearcher = New-Object System.DirectoryServices.DirectorySearcher
		$objSearcher.SearchRoot = $objDomain
		$objSearcher.PageSize = 1000
		$objSearcher.Filter = $strFilter
		$objSearcher.SearchScope = "Subtree"
		$colProplist = "name"
		foreach ($i in $colProplist){$objSearcher.PropertiesToLoad.Add($i) | Out-Null}
		$colResults = $objSearcher.FindAll()
		if ($colResults.Count -gt 0) {
			$msg  = "Active Directory schema has been extended for configmgr"
		} else {
			$stat = $except
			$msg  = "Active Directory schema has NOT been extended for configmgr"
		}
	}
	catch {
		$stat = 'ERROR'
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