function Test-CmBoundaryDuplicates {
	[CmdletBinding()]
	[OutputType()]
	param (
		[parameter()][string] $TestName = "Duplicate Site Boundaries",
		[parameter()][string] $TestGroup = "configuration",
		[parameter()][string] $TestCategory = "CM",
		[parameter()][string] $Description = "Validate Site Boundaries are not duplicated",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		$startTime = (Get-Date)
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat   = "PASS"
		$except = "FAIL"
		$msg   = "No issues found"
		$query = "select * from vSMS_Boundary"
		$boundaries = Get-CmSqlQueryResult -Query $query -Params $ScriptParams
		$dupes = @($boundaries | Group-Object -Property BoundaryType,Value | Select-Object Count,Name)
		if (($dupes | Where-Object {$_.Count -gt 1}) -gt 0) {
			$stat = $except
			foreach ($dupe in $dupes) {
				$tempData.Add([pscustomobject]@{Boundary=$($dupe.Name);Count=$($dupe.Count)})
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
