function Test-CmClientHealth {
	[CmdletBinding()]
	[OutputType()]
	param (
		[parameter()][string] $TestName = "Client Health Summary",
		[parameter()][string] $TestGroup = "operation",
		[parameter()][string] $TestCategory = "CM",
		[parameter()][string] $Description = "ConfigMgr Client Health Status",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		$startTime = (Get-Date)
		#[int]$Setting = Get-CmHealthDefaultValue -KeySet "keygroup:keyname" -DataSet $CmHealthConfig
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat   = "PASS" # do not change this
		$except = "WARNING" # or "FAIL"
		$msg    = "No issues found" # do not change this either
		# credit to Trevor Jones for the following query at https://smsagent.blog/2016/02/05/client-health-find-all-ccmeval-failed-or-unknown/
		$query = "Select sys.Name0 as 'ComputerName',
sys.User_Name0 as 'UserName',
cs.ClientStateDescription,
DATEDIFF(day,sys.Creation_Date0,cs.LastActiveTime) as 'DaysActive',
DATEDIFF(day,cs.LastHealthEvaluation,GetDate()) as 'DaysSinceLastEval',
sys.Creation_Date0 as 'ClientRegistrationDate',
cs.LastActiveTime, 
cs.LastHealthEvaluation,
case when LastEvaluationHealthy = 1 then 'Pass'
	when LastEvaluationHealthy = 2 then 'Fail'
	when LastEvaluationHealthy = 3 then 'Unknown'
	end as 'Last Evaluation Healthy',
case when cs.ClientRemediationSuccess = 1 then 'Pass'
	when cs.ClientRemediationSuccess = 2 then 'Fail'
	else ''
	end as 'ClientRemediationSuccess',
case when LastHealthEvaluationResult = 1 then 'Not Yet Evaluated'
	when LastHealthEvaluationResult = 2 then 'Not Applicable'
	when LastHealthEvaluationResult = 3 then 'Evaluation Failed'
	when LastHealthEvaluationResult = 4 then 'Evaluated Remediated Failed'
	when LastHealthEvaluationResult = 5 then 'Not Evaluated Dependency Failed'
	when LastHealthEvaluationResult = 6 then 'Evaluated Remediated Succeeded'
	when LastHealthEvaluationResult = 7 then 'Evaluation Succeeded'
	end as 'LastHealthEvaluationResult',
HealthCheckDescription,
ResultDetail,
ResultCode
from dbo.v_CH_ClientSummary cs
inner join v_R_System sys on cs.ResourceID = sys.ResourceID
left join v_CH_EvalResults eval on cs.ResourceID = eval.ResourceID
where cs.ClientStateDescription in ('Active/Fail','Active/Unknown')
and DATEDIFF(day,sys.Creation_Date0,cs.LastActiveTime) > 7
Order by ClientStateDescription,ComputerName"
		[array]$res = Get-CmSqlQueryResult -Query $query -Params $ScriptParams
		if ($res.Count -gt 0) {
			$stat = $except
			$msg = "$($res.Count) clients are reporting as not healthy"
		}
		$res | Foreach-Object {
			$tempdata.Add(
				[pscustomobject]@{
					ComputerName = $_.ComputerName
					UserName     = $_.UserName
					LastEval     = $_.'Last Evaluation Healthy'
					Remediation  = $_.'ClientRemediationSuccess'
					EvalResult   = $_.'LastHealthEvaluationResult'
				}
			)
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