function Test-CmBoundariesDuplicates {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Test-CmBoundariesDuplicates",
		[parameter()][string] $TestGroup = "configuration",
		[parameter()][string] $Description = "Validate Site Boundaries are not duplicated",
		[parameter()][hashtable] $ScriptParams
	)
	try {
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
