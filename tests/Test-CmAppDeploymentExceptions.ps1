function Test-CmAppDeploymentExceptions {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Test-CmAppDeploymentExceptions",
		[parameter()][string] $TestGroup = "operation",
		[parameter()][string] $Description = "Summary of application deployment failures",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		#[int]$Setting = Get-CmHealthDefaultValue -KeySet "keygroup:keyname" -DataSet $CmHealthConfig
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat = "PASS" # do not change this
		$msg  = "No issues found" # do not change this either
		$query = "select
	ads.Descript AS DeploymentName,
	ads.TargetCollectionID,
	coll.Name AS CollectionName,
	ads.AssignmentID,
	ads.DeploymentTime,
	case
		when ads.OfferTypeID = 0 then 'Required'
		else 'Available' END AS OfferType,
	ads.AlreadyPresent,
	(ads.Success + ads.Error + ads.InProgress + ads.Unknown + ads.RequirementsNotMet) as Total,
	ads.Success,
	ads.InProgress,
	ads.Unknown,
	ads.Error,
	ads.RequirementsNotMet
from
	v_AppDeploymentSummary as ads inner join
	v_Collection as coll on ads.TargetCollectionID = coll.CollectionID
where (ads.Error > 0)
order by DeploymentName"
		if ($ScriptParams.Credential) {
			$res = @(Invoke-DbaQuery -SqlInstance $ScriptParams.SqlInstance -Database $ScriptParams.Database -Query $query -SqlCredential $ScriptParams.Credential)
		} else {
			$res = @(Invoke-DbaQuery -SqlInstance $ScriptParams.SqlInstance -Database $ScriptParams.Database -Query $query)
		}
		
		if ($res.Count -gt 0) {
			$stat = "WARNING" # or "FAIL"
			$msg  = "$($res.Count) items found"
			$res | Foreach-Object {$tempdata.Add($_.DeploymentName)}
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
