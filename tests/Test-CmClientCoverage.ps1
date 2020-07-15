function Test-CmClientCoverage {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "CM Client Coverage",
		[parameter()][string] $TestGroup = "operation",
		[parameter()][string] $Description = "Confirm AD computers managed by CM",
		[parameter()][hashtable] $ScriptParams,
		[parameter()][int] $Threshold = 0.9
	)
	try {
		$tempdata = $null
		$adcomps = @(Get-AdsiComputer | Select-Object -ExpandProperty Name)
		$query = "select distinct name, clientversion, lasthardwarescan from dbo.v_CombinedDeviceResources where (name not like '%unknown%')"
		$cmcomps = @(Invoke-DbaQuery -SqlInstance $ScriptParams.SqlInstance -Database $ScriptParams.Database -Query $query)
		if ($adcomps.Count -gt 0 -and $cmcomps.Count -gt 0) {
			if (($adcomps.Count / $cmcomps.Count) -ge $Threshold) {
				$stat = 'PASS'
				$msg  = "Coverage meets stated threshold of $($Threshold * 100) percent"
			} else {
				$stat = 'FAIL'
				$msg  = "Coverage does not meet threshold of $($Threshold * 100) percent"
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
		})
	}
}
