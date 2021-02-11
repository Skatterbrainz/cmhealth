function Test-CmContentDistErrors {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Test-CmContentDistErrors",
		[parameter()][string] $TestGroup = "operation",
		[parameter()][string] $Description = "Check for content with distribution errors",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		$startTime = (Get-Date)
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat   = "PASS"
		$except = "WARNING"
		$msg    = "No issues found"
		$query = "SELECT
SELECT cds.PkgID as PackageID, pkg.Name, pkg.Version, cds.TargeteddDPCount, cds.NumberInstalled, cds.NumberInProgress, cds.NumberErrors, pkg.PackageType
FROM dbo.v_ContDistStatSummary AS cds INNER JOIN
dbo.v_Package AS pkg ON cds.PkgID = pkg.PackageID
WHERE (cds.NumberErrors > 0)"
		$res = Get-CmSqlQueryResult -Query $query -Params $ScriptParams
		if ($res.Count -gt 1) {
			$stat = $except
			$msg = "$($res.Count) packages with distribution errors"
			$res | Foreach-Object {$tempdata.Add("PkgID=$($_.PkgID),Name=$($_.Name),Errors=$($_.NumberErrors)")}
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