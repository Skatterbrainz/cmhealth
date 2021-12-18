function Test-CmClientATPStatus {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "ATP Client Onboarding and Activity Status",
		[parameter()][string] $TestGroup = "operation",
		[parameter()][string] $TestCategory = "CM",
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
		$query = "select distinct [ATP_OnboardingState] as ATPOnboard, Count(*) as Devices 
from v_CombinedDeviceResources where Name not in 
('x86 Unknown Computer (x86 Unknown Computer)','x64 Unknown Computer (x64 Unknown Computer)',
'Provisioning Device (Provisioning Device)')
group by [ATP_OnboardingState]"
		$res = Get-CmSqlQueryResult -Query $query -Params $ScriptParams
		if ($res.Count -gt 0) {
			$onboard = $res | Where-Object {$_.ATPOnboard -eq 1}
			$total = $($res.Devices | Measure-Object -Sum | Select-Object -ExpandProperty Sum)
			$pending = $total - $onboard
			if (($onboard -gt 0) -and ($pending -gt 0)) {
				$stat = $except
				$msg  = "$($res.Count) items found"
				$res | Foreach-Object {
					$tempdata.Add(
						[pscustomobject]@{
							ATPOnboard = $_.ATPOnboard
							Devices = $_.Devices
						}
					)
				}
			}
		}
	}
	catch {
		$stat = 'ERROR'
		$msg  = "$($_.Exception.Message -join ';')"
		$msg += " / trace: $($_.ScriptStackTrace -join ';')"
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
