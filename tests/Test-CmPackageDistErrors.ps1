function Test-CmPackageDistErrors {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Test-CmPackageDistErrors",
		[parameter()][string] $TestGroup = "operation",
		[parameter()][string] $Description = "Packages with content distribution errors",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat = "PASS" # do not change this
		$msg  = "No issues found" # do not change this either
		$query = "SELECT 
pkg.PackageID, pkg.Name, cds.NumberInstalled, cds.NumberInProgress, 
cds.NumberErrors, pkg.Description, pkg.PkgSourcePath
FROM dbo.v_ContDistStatSummary AS cds INNER JOIN
dbo.v_Package AS pkg ON cds.PkgID = pkg.PackageID
WHERE (cds.NumberErrors > 0)"
		if ($ScriptParams.Credential) { 
			$res = @(Invoke-DbaQuery -SqlInstance $ScriptParams.SqlInstance -Database $ScriptParams.Database -Query $query -SqlCredential $ScriptParams.Credential)
		} else {
			$res = @(Invoke-DbaQuery -SqlInstance $ScriptParams.SqlInstance -Database $ScriptParams.Database -Query $query)
		}
		if ($null -ne $res -and $res.Count -gt 0) {
			$stat = "FAIL"
			$msg  = "$($res.Count) items found: $($res.Name -join ',')"
			$res | Foreach-Object {$tempdata.Add("ID=$($_.PackageID),Name=$($_.Name),Errors=$($_.NumberErrors),SourcePath=$($_.PkgSourcePath)")}
		}
	}
	catch {
		$stat = 'ERROR'
		$msg = $_.Exception.Message -join ';'
	}
	finally {
		Write-Output $([pscustomobject]@{
			TestName    = $TestName
			TestGroup   = $TestGroup
			TestData    = $tempdata
			Description = $Description
			Status      = $stat 
			Message     = $msg
			Credential  = $(if($ScriptParams.Credential){$($ScriptParams.Credential).UserName} else { $env:USERNAME })
		})
	}
}
