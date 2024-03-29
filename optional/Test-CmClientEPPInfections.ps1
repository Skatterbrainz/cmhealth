function Test-CmClientEPPInfections {
	[CmdletBinding()]
	[OutputType()]
	param (
		[parameter()][string] $TestName = "Check for Endpoint Protection Infections",
		[parameter()][string] $TestGroup = "operation",
		[parameter()][string] $TestCategory = "CM",
		[parameter()][string] $Description = "Query history of EP client infections",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		$startTime = (Get-Date)
		#[int]$Setting = Get-CmHealthDefaultValue -KeySet "keygroup:keyname" -DataSet $CmHealthConfig
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat   = "PASS" # do not change this
		$except = "WARNING" # or "FAIL"
		$msg    = "No issues found" # do not change this either
		$query = "select Name,EP_LastThreatName,EP_LastInfectionTime from dbo.v_CombinedDeviceResources where EP_LastThreatName IS NOT NULL order by Name"
		$res = Get-CmSqlQueryResult -Query $query -Params $ScriptParams
		if ($res.Count -gt 0) {
			$stat = $except
			$msg  = "$($res.Count) items found"
			$res | Foreach-Object {
				$tempdata.Add(
					[pscustomobject]@{
						DeviceName = $_.Name
						ThreatName = $_.EP_LastThreatName
						DateTime   = $_.EP_LastInfectionTime
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
