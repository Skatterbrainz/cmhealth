function Test-CmClientInventoryMissing {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Clients Missing Inventory Data",
		[parameter()][string] $TestGroup = "operation",
		[parameter()][string] $TestCategory = "CM",
		[parameter()][string] $Description = "Clients with no inventory data",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		$startTime = (Get-Date)
		[int] $DaysOld = Get-CmHealthDefaultValue -KeySet "configmgr:MaxClientInventoryDaysOld" -DataSet $CmHealthConfig
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat   = "PASS" # do not change this
		$except = "WARNING"
		$msg    = "No issues found" # do not change this either
		$query = "SELECT DISTINCT fcm.Name,
sys.Client_Version0,
fcm.Domain,
sys.User_Name0,
fcm.SiteCode,
chs.LastActiveTime AS AgentTime,
chs.LastHW AS LastHWScan,
chs.LastSW AS LastScanDate
FROM v_FullCollectionMembership fcm
INNER JOIN v_R_System sys ON fcm.ResourceID = sys.ResourceID
INNER JOIN v_CH_ClientSummary chs ON chs.ResourceID = fcm.ResourceID AND chs.ClientActiveStatus = 0 
WHERE fcm.CollectionID = 'SMS00001' AND 
chs.LastHW IS NULL
ORDER BY fcm.Name"
		$res = Get-CmSqlQueryResult -Query $query -Params $ScriptParams
		if ($res.Count -gt 0) {
			$stat = $except
			$msg  = "$($res.Count) clients inventory older than $($DaysOld) days"
			Write-Log -Message $msg
			$res | Foreach-Object {
				$tempdata.Add(
					[pscustomobject]@{
						Name   = $_.Name
						Client = $_.Client_Version0
						LastHW = $_.LastHWScan
						LastActive = $_.AgentTime
						SiteCode = $_.SiteCode
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
