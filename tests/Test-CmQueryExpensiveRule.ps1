function Test-CmQueryExpensiveRule {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Expensive Query Membership Rules",
		[parameter()][string] $TestGroup = "configuration",
		[parameter()][string] $Description = "Check for queries which are processing-intensive",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		$startTime = (Get-Date)
		#[int]$Setting = Get-CmHealthDefaultValue -KeySet "keygroup:keyname" -DataSet $CmHealthConfig
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat   = "PASS" # do not change this
		$except = "WARNING" # or "FAIL"
		$msg  = "No issues found" # do not change this either
		$query = "select CollectionName,SiteID,QueryName,SQL,WQL
from dbo.Collection_Rules_SQL c1
INNER JOIN dbo.Collection_Rules c2 ON c1.CollectionID = c2.CollectionID
INNER JOIN v_Collections c3 ON c1.CollectionID = c3.CollectionID
where c3.SiteID not like 'SMS%'"
		$res = Get-CmSqlQueryResult -Query $query -Params $ScriptParams
		foreach ($row in $res) {
			if ($row.SQL -match "'%" -and $row.SQL -match "%'") {
				$stat = $except
				$tempdata.Add(
					[pscustomobject]@{
						QueryName = $row.QueryName
						Collection = $row.CollectionName
						CollectionID = $row.SiteID
						Message = "LIKE with a leading and trailing wildcard"
						Query = $row.WQL
					}
				)
			} elseif ($row.SQL -match "'%") {
				$stat = $except
				$tempdata.Add(
					[pscustomobject]@{
						QueryName = $row.QueryName
						Collection = $row.CollectionName
						CollectionID = $row.SiteID
						Message = "LIKE with a leading wildcard"
						Query = $row.WQL
					}
				)
			}
		} # foreach
		if ($tempdata.Count -gt 0) {
			$stat = $except
			$msg  = "$($tempdata.Count) expensive queries were found"
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
			RunTime     = $(Get-RunTime -BaseTime $startTime)
			Credential  = $(if($ScriptParams.Credential){$($ScriptParams.Credential).UserName} else { $env:USERNAME })
		})
	}
}
