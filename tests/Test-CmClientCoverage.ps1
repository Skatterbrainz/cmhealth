function Test-CmClientCoverage {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Device Client Coverage Status",
		[parameter()][string] $TestGroup = "operation",
		[parameter()][string] $Description = "Confirm AD computers managed by CM",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		$startTime = (Get-Date)
		[int]$Coverage = Get-CmHealthDefaultValue -KeySet "configmgr:ClientCoverageThresholdPercent" -DataSet $CmHealthConfig
		Write-Verbose "coverage threshold = $Coverage percent"
		$stat   = "PASS"
		$except = "WARNING"
		$msg    = "Coverage meets stated threshold of $Coverage percent"
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$adcomps = @(Get-AdsiComputer | Select-Object -ExpandProperty Name) # array of AD computer names
		$adcount = $adcomps.Count
		Write-Verbose "AD computers = $adcount"
		$query = "select distinct name, clientversion, lasthardwarescan 
from dbo.v_CombinedDeviceResources 
where (name not like '%unknown%') and (name not like 'Provisioning Device%')"
		$cmcomps = Get-CmSqlQueryResult -Query $query -Params $ScriptParams
		$cmcount = $cmcomps.Count
		Write-Verbose "CM computers = $cmcount"
		if (($adcount -gt 0) -and ($cmcount -gt 0)) {
			$delta1 = $cmcomps | Where-Object {$_.name -notin $adcomps} # CM device names not in AD
			$delta2 = $adcomps | Where-Object {$_ -notin $cmcomps.name} # AD computer names not in CM
			Write-Verbose "there are $($delta1.Count) computers in configmgr which are not in active directory"
			Write-Verbose "there are $($delta2.Count) computers in active directory which are not in configmgr"
			if (($delta1.Count -gt 0) -or ($delta2.Count -gt 0)) {
				$stat = $except
				$msg = "discrepancies found between configmgr and active directory computer coverage"
				$d1names = $delta1.name -join ','
				$d2names = $delta2 -join ','
				$tempdata.Add(
					[pscustomobject]@{
						ADComputers = $($adcomps.Count)
						CMComputers = $($cmcomps.Count)
						OnlyAD  = $d2names
						OnlyCM  = $d1names
						NotInAD = $($delta1.Count)
						NotInCM = $($delta2.Count)
					}
				)
			}
		} else {
			$stat = $except
			$msg  = "Unable to query environment data to validate this test"
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
