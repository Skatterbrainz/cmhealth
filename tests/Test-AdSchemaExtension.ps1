function Test-AdSchemaExtension {
	[CmdletBinding()]
	[OutputType()]
	param (
		[parameter()][string] $TestName = "Active Directory Schema Extended",
		[parameter()][string] $TestGroup = "configuration",
		[parameter()][string] $TestCategory = "AD",
		[parameter()][string] $Description = "Verify AD schema extensions have been installed",
		[parameter()][hashtable] $ScriptParams
	)
	$startTime = (Get-Date)
	$stat = "PASS"
	$except = "FAIL"
	try {
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		Write-Log -Message "Verifying for AD Schema extension"
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
			Write-Log -Message "schema has been extended"
			foreach ($item in $colResults) {
				$obj = Get-ADSIObject -Identity $item.Path.Substring(7)
				$msg  = "Active Directory schema has been extended for configmgr"
				$tempdata.Add(
					[pscustomobject]@{
						ObjectName  = $obj.name
						Container   = $obj.adspath
						DateCreated = $obj.whencreated
						DateChanged = $obj.whenchanged
						Status      = 'Extended'
					}
				)
			}
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
		Set-CmhOutputData
	}
}