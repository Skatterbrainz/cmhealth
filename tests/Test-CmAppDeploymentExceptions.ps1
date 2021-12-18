function Test-CmAppDeploymentExceptions {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Application Deployment Exceptions",
		[parameter()][string] $TestGroup = "operation",
		[parameter()][string] $TestCategory = "CM",
		[parameter()][string] $Description = "Summary of application deployment failures",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		$startTime = (Get-Date)
		#[int]$Setting = Get-CmHealthDefaultValue -KeySet "keygroup:keyname" -DataSet $CmHealthConfig
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat   = "PASS" # do not change this
		$except = "WARNING"
		$msg  = "No issues found" # do not change this either
		$query = "select
ads.Descript AS DeploymentName,
ads.TargetCollectionID,
coll.Name AS CollectionName,
ads.AssignmentID,
ads.DeploymentTime,
case when ads.OfferTypeID = 0 then 'Required'
else 'Available' END AS OfferType,
ads.AlreadyPresent,
(ads.Success + ads.Error + ads.InProgress + ads.Unknown + ads.RequirementsNotMet) as Total,
ads.Success,
ads.InProgress,
ads.Unknown,
ads.Error,
ads.RequirementsNotMet
from v_AppDeploymentSummary as ads inner join
v_Collection as coll on ads.TargetCollectionID = coll.CollectionID
where (ads.Error > 0)
order by DeploymentName"
		$res = Get-CmSqlQueryResult -Query $query -Params $ScriptParams
		if ($res.Count -gt 0) {
			$stat = $except
			$msg  = "$($res.Count) items found"
			$res | Foreach-Object {
				$tempdata.Add(
					[pscustomobject]@{
						Deployment = $_.DeploymentName
						CollectionID = $_.CollectionID
						CollectionName = $_.CollectionName
						OfferType = $_.OfferType
						Total = $_.Total
						Success = $_.Success
						InProgress = $_.InProgress
						Unknown = $_.Unknown
						Failed = $_.Error
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
