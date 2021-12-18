<#
.NOTES
	Adapted from example:
	Source: https://model-technology.com/blog/troubleshooting-slow-collection-evaluation-in-sccm-2012-part-3-aka-how-to-identify-collection-update-loitering/
	By original author: Steve Bowman
#>
function Test-CmCollectionRefresh {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Collection Refresh Performance",
		[parameter()][string] $TestGroup = "configuration",
		[parameter()][string] $TestCategory = "CM",
		[parameter()][string] $Description = "Validate Collections refresh impact on performance",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		$startTime = (Get-Date)
		[int]$maxcolls  = Get-CmHealthDefaultValue -KeySet "configmgr:MaxCollectionRefreshCount" -DataSet $CmHealthConfig
		Write-Log -Message "max collections allowed = $maxcolls"
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat   = "PASS"
		$except = "WARNING"
		$msg    = "No issues found"
		$query = "Select
case
	when RefreshType = 1 then 'Manual'
	when RefreshType = 2 then 'Scheduled'
	when RefreshType = 4 then 'Incremental'
	when RefreshType = 6 then 'Scheduled and Incremental'
	else 'Unknown' 
	end as RefreshType,
SiteID, CollectionName, MemberCount,
case when CollectionType = 2 then 'Device' 
else 'User' 
end as CollectionType
from dbo.v_Collections
where RefreshType in (2,4,6)
order by CollectionName"
		$res = Get-CmSqlQueryResult -Query $query -Params $ScriptParams
		if ($res.Count -gt $maxcolls) {
			$stat = $except
			$msg  = "$($cc.Count) collections are set to incremental and/or scheduled refresh."
			$msg += "Maximum recommended limit is $maxcolls"
			Write-Log -Message $msg
			$res | Foreach-Object {
				$tempdata.Add(
					[pscustomobject]@{
						ID = $_.SiteID
						Name = $_.CollectionName
						Type = $_.CollectionType
						RefreshType = $_.RefreshType
						Members = $_.MemberCount
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
