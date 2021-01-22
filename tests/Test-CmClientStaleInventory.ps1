function Test-CmClientStaleInventory {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Test-CmClientStaleInventory",
		[parameter()][string] $TestGroup = "operation",
		[parameter()][string] $Description = "Clients with outdated or missing inventory data",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		[int] $DaysOld = Get-CmHealthDefaultValue -KeySet "configmgr:MaxClientInventoryDaysOld" -DataSet $CmHealthConfig
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat = "PASS" # do not change this
		$msg  = "No issues found" # do not change this either
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
WHERE fcm.CollectionID = 'SMS00001' AND chs.LastActiveTime < DATEADD(dd,-CONVERT(INT,$($DaysOld)),GETDATE())"
		if ($ScriptParams.Credential) {
			$res = @(Invoke-DbaQuery -SqlInstance $ScriptParams.SqlInstance -Database $ScriptParams.Database -Query $query -SqlCredential $ScriptParams.Credential)
		} else {
			$res = @(Invoke-DbaQuery -SqlInstance $ScriptParams.SqlInstance -Database $ScriptParams.Database -Query $query)
		}
		if ($null -ne $res -and $res.Count -gt 0) {
			$stat = "WARNING" # or "FAIL"
			$msg  = "$($res.Count) clients inventory older than $($DaysOld) days: $($res.Name -join ',')"
			$res | Foreach-Object {$tempdata.Add("Name=$($_.Name),LastHW=$($_.LastHWScan),SiteCode=$($_.SiteCode)")}
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
