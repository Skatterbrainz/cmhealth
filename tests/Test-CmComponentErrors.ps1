function Test-CmComponentErrors {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Site Component Errors",
		[parameter()][string] $TestGroup = "operation",
		[parameter()][string] $Description = "Site Component Errors and Warnings",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		$startTime = (Get-Date)
		#[int]$Setting = Get-CmHealthDefaultValue -KeySet "keygroup:keyname" -DataSet $CmHealthConfig
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat   = "PASS" # do not change this
		$except = "WARNING" # or "FAIL"
		$msg    = "No issues found" # do not change this either
		$query = "Select 
ComponentName,
ComponentType,
Case
when Status = 0 then 'OK'
when Status = 1 then 'Warning'
when Status = 2 then 'Critical'	
End as 'Status',
Case
when State = 0 then 'Stopped'
when State = 1 then 'Started'
when State = 2 then 'Paused'
when State = 3 then 'Installing'
when State = 4 then 'Re-installing'
when State = 5 then 'De-installing'
End as 'State',
Case
When AvailabilityState = 0 then 'Online'
When AvailabilityState = 3 then 'Offline'
When AvailabilityState = 4 then 'Unknown'
End as 'AvailabilityState',
Infos,
Warnings,
Errors
from vSMS_ComponentSummarizer
where TallyInterval = N'0001128000100008'
and MachineName = 'vm-sccmsite-01.uhs.med'
and SiteCode = 'S02'
and Status in (1,2)
Order by Status,ComponentName"
		$res = Get-CmSqlQueryResult -Query $query -Params $ScriptParams
		if ($res.Count -gt 0) {
			$stat = $except
			$msg  = "$($res.Count) component status issues found"
			$res | Foreach-Object {
				$tempdata.Add(
					[pscustomobject]@{
						ComponentName = $_.ComponentName
						ComponentType = $_.ComponentType
						Status = $_.Status
						State  = $_.State
						AvailabilityState = $_.AvailabilityState
						Info = $_.Infos
						Warnings = $_.Warnings
						Errors = $_.Errors
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