function Test-CmBoundariesOrphaned {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Orphaned Site Boundaries",
		[parameter()][string] $TestGroup = "configuration",
		[parameter()][string] $TestCategory = "CM",
		[parameter()][string] $Description = "Validate Site Boundaries are in Boundary Groups",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		$startTime = (Get-Date)
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat   = "PASS"
		$except = "FAIL"
		$msg    = "No issues found"
		$query  = "select * from vSMS_Boundary where GroupCount < 1 and DisplayName not like '%Default-First-Site-Name'"
		$res = Get-CmSqlQueryResult -Query $query -Params $ScriptParams
		if ($res.Count -gt 1) {
			$stat = $except
			$msg = "$($res.Count) boundaries found not in a boundary group"
			$res | Foreach-Object {
				$tempdata.Add(
					[pscustomobject]@{
						Name = $($_.DisplayName)
						Scope = $($_.Value)
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
		$([pscustomobject]@{
			TestName    = $TestName
			TestGroup   = $TestGroup
			Category    = $TestCategory
			TestData    = $tempdata
			Description = $Description
			Status      = $stat
			Message     = $msg
			RunTime     = $(Get-RunTime -BaseTime $startTime)
			Credential  = $(if($ScriptParams.Credential){$($ScriptParams.Credential).UserName} else { $env:USERNAME })
		})
	}
}
