function Test-CmPackageDistErrors {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Package Distribution Errors",
		[parameter()][string] $TestGroup = "operation",
		[parameter()][string] $TestCategory = "CM",
		[parameter()][string] $Description = "Check for Packages with content distribution errors",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		$startTime = (Get-Date)
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat   = "PASS" # do not change this
		$except = "FAIL"
		$msg    = "No issues found" # do not change this either
		$query = "SELECT 
pkg.PackageID, pkg.Name, cds.NumberInstalled, cds.NumberInProgress,
cds.NumberErrors, pkg.Description, pkg.PkgSourcePath
FROM dbo.v_ContDistStatSummary AS cds INNER JOIN
dbo.v_Package AS pkg ON cds.PkgID = pkg.PackageID
WHERE (cds.NumberErrors > 0)"
		$res = Get-CmSqlQueryResult -Query $query -Params $ScriptParams
		if ($null -ne $res -and $res.Count -gt 0) {
			$stat = $except
			$msg  = "$($res.Count) items found: $($res.Name -join ',')"
			$res | Foreach-Object {
				$tempdata.Add(
					[pscustomobject]@{
						ID = $($_.PackageID)
						Name = $($_.Name)
						Errors = $($_.NumberErrors)
						SourcePath = $($_.PkgSourcePath)
					}
				)
			}
		}
	}
	catch {
		$stat = 'ERROR'
		$msg = $_.Exception.Message -join ';'
	}
	finally {
		Set-CmhOutputData
	}
}
