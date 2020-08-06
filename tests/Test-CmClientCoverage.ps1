function Test-CmClientCoverage {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Test-CmClientCoverage",
		[parameter()][string] $TestGroup = "operation",
		[parameter()][string] $Description = "Confirm AD computers managed by CM",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		[int]$Coverage = Get-CmHealthDefaultValue -KeySet "configmgr:ClientCoverageThresholdPercent" -DataSet $CmHealthConfig
		$Threshold = $Coverage * 0.1
		Write-Verbose "coverage threshold = $Coverage percent"
		$stat = "PASS"
		$msg  = "Coverage meets stated threshold of $Coverage percent"
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$adcomps = @(Get-AdsiComputer | Select-Object -ExpandProperty Name)
		$adcount = $adcomps.Count
		Write-Verbose "AD computers = $adcount"
		$query = "select distinct name, clientversion, lasthardwarescan from dbo.v_CombinedDeviceResources where (name not like '%unknown%')"
		if ($ScriptParams.Credential) {
			$cmcomps = @(Invoke-DbaQuery -SqlInstance $ScriptParams.SqlInstance -Database $ScriptParams.Database -Query $query -SqlCredential $ScriptParams.Credential)
		} else {
			$cmcomps = @(Invoke-DbaQuery -SqlInstance $ScriptParams.SqlInstance -Database $ScriptParams.Database -Query $query)
		}
		$cmcount = $cmcomps.Count
		Write-Verbose "CM computers = $cmcount"
		if (($adcount -gt 0) -and ($cmcount -gt 0)) {
			$actual = $($cmcount / $adcount) * 100
			Write-Verbose "actual = $actual"
			if ($actual -lt $Coverage) {
				$stat  = 'WARNING'
				$msg   = "$actual percent coverage is below the minimum threshold of $Coverage percent"
				$tempdata.Add( @{AD_Count = $adcount; CM_Count = $cmcount} )
			} else {
				$msg = "$actual percent coverage is above the minimum threshold of $Coverage percent"
			}
		} else {
			$stat = 'FAIL'
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
			Credential  = $(if($ScriptParams.Credential){$($ScriptParams.Credential).UserName} else { $env:USERNAME })
		})
	}
}
