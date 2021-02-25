function Test-ATPClientStatus {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "ATP Client Onboarding and Activity Status",
		[parameter()][string] $TestGroup = "operation",
		[parameter()][string] $Description = "ATP Devices onboarded and active",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		$startTime = (Get-Date)
		#[int]$Setting = Get-CmHealthDefaultValue -KeySet "keygroup:keyname" -DataSet $CmHealthConfig
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat   = "PASS" # do not change this
		$except = "WARNING" # or "FAIL"
		$msg    = "No issues found" # do not change this either
		$query = "select distinct ATP_OnboadingState as ATPOnboard,count(*) as Devices from dbo.v_CombinedDeviceResources group by ATP_OnboardingState"
		#$query = "select Name,ATP_OnboardingState,ATP_LastConnected from v_CombinedDeviceResources"
		$res = Get-CmSqlQueryResult -Query $query -Params $ScriptParams
		if ($res.Count -gt 0) {
			$onboard = $res | Where-Object {$_.ATPOnboard -eq 1}
			$total = $($res.Devices | Measure-Object -Sum).Sum
			$pending = $total - $onboard
			if (($onboard -gt 0) -and ($pending -gt 0)) {
				$stat = $except
				$msg  = "$($res.Count) items found"
				#$res | Foreach-Object {$tempdata.Add( [pscustomobject]@{Name=$_.Name} )}
			}
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
