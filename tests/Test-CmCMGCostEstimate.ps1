function Test-CmCMGCostEstimate {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Estimated CMG Operational Cost Estimate",
		[parameter()][string] $TestGroup = "operation",
		[parameter()][string] $TestCategory = "CM",
		[parameter()][string] $Description = "CMG Per Client Average Data usage",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		$startTime = (Get-Date)
		#[int]$Setting = Get-CmHealthDefaultValue -KeySet "keygroup:keyname" -DataSet $CmHealthConfig
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat   = "PASS" # do not change this
		$except = "WARNING" # or "FAIL"
		$msg    = "No issues found" # do not change this either
		$query = "select * from v_CloudCostEstimatorData"
		# returns: ID (aka sitecode), LaptopCount(int), DesktopCount(int), ServerCount(int), clientCount(int), AvgMPMBPerMonthPerClient(int), AvgContentMBPerMonthPerClient(int)
		$res = Get-CmSqlQueryResult -Query $query -Params $ScriptParams
		if ($res.Count -gt 0) {
			$stat = $except
			$msg  = "$($res.Count) items found"
			$res | Foreach-Object {
				$tempdata.Add(
					[pscustomobject]@{
						SiteCode=$_.ID
						Laptops = $_.LaptopCount
						Desktops = $_.DesktopCount
						Servers = $_.ServerCount
						Clients = $_.clientCount
						AvgPerClientMPMB = $_.AvgMPMBPerMonthPerClient
						AvgPerClientContentMB = $_.AvgContentMBPerMonthPerClient
					}
				)
			}
		} else {
			$msg = "No CMG costs are available"
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
