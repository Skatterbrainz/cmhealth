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
		[parameter()][string] $Description = "Validate Collections refresh impact on performance",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		$startTime = (Get-Date)
		[int]$maxcolls  = Get-CmHealthDefaultValue -KeySet "configmgr:MaxCollectionRefreshCount" -DataSet $CmHealthConfig
		Write-Verbose "max collections = $maxcolls"
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat   = "PASS"
		$except = "WARNING"
		$msg    = "No issues found"
		$query = "Select
(case
when RefreshType = 1 then 'Manual'
when RefreshType = 2 then 'Scheduled'
when RefreshType = 4 then 'Incremental'
when RefreshType = 6 then 'Scheduled and Incremental'
else 'Unknown' end) as RefreshType,
SiteID, CollectionName
from v_Collections"
		$res = Get-CmSqlQueryResult -Query $query -Params $ScriptParams
		$cc = ($res | Where-Object {$_.RefreshType -in ('Incremental','Scheduled','Scheduled and Incremental')})
		if ($cc.Count -gt $maxcolls) {
			$stat = $except
			$msg  = "Found $($cc.Count) collections are set to incremental or scheduled refresh"
			$c1 | Foreach-Object {
				$tempdata.Add(
					[pscustomobject]@{
						ID = $_.SiteID
						Name = $_.CollectionName
						RefreshType = $_.RefreshType
					}
				)
			}
			$c2 | Foreach-Object {
				$tempdata.Add(
					[pscustomobject]@{
						ID = $_.SiteID
						Name = $_.CollectionName
						RefreshType = $_.RefreshType
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
