function Test-AdSchemaExtension {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "AD Schema Extension",
		[parameter()][string] $TestGroup = "configuration",
		[parameter()][string] $Description = "Verify AD schema extensions have been installed",
		[parameter()][string] $ComputerName = "localhost"
	)
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
			$stat = 'PASS'
			$msg  = "Active Directory schema has been extended for configmgr"
		} else {
			$stat = 'FAIL'
			$msg  = "Active Directory schema has not been extended for configmgr"
		}
	}
	catch {
		$stat = 'ERROR'
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