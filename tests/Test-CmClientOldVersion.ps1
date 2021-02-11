function Test-CmClientOldVersion {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Test-CmClientOldVersion",
		[parameter()][string] $TestGroup = "operation",
		[parameter()][string] $Description = "Check for clients with version older than site version",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		$startTime = (Get-Date)
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat   = "PASS" # do not change this
		$except = "WARNING"
		$msg    = "No issues found" # do not change this either
		$query = "SELECT DISTINCT fcm.Name,
sys.Client_Version0,
fcm.Domain,
sys.User_Name0,
fcm.SiteCode
FROM v_FullCollectionMembership_Valid fcm
INNER JOIN v_R_System_Valid sys ON fcm.ResourceID = sys.ResourceID
INNER JOIN v_Site st ON st.SiteCode = fcm.SiteCode
WHERE fcm.CollectionID = 'SMS00001' AND sys.Client_Version0 < st.Version"
		if ($null -ne $ScriptParams.Credential) {
			$res = @(Invoke-DbaQuery -SqlInstance $ScriptParams.SqlInstance -Database $ScriptParams.Database -Query $query -SqlCredential $ScriptParams.Credential)
		} else {
			$res = @(Invoke-DbaQuery -SqlInstance $ScriptParams.SqlInstance -Database $ScriptParams.Database -Query $query)
		}
		if ($null -ne $res -and $res.Count -gt 0) {
			$stat = $except
			$msg  = "$($res.Count) items found: $($res.Name -join ',')"
			$res | Foreach-Object {$tempdata.Add("Name=$($_.Name),Version=$($_.Client_Version0)")}
		}
	}
	catch {
		$stat = 'ERROR'
		$msg = $_.Exception.Message -join ';'
	}
	finally {
		$endTime = (Get-Date)
		$runTime = $(New-TimeSpan -Start $startTime -End $endTime)
		$rt = "{0}h:{1}m:{2}s" -f $($runTime | Foreach-Object {$_.Hours,$_.Minutes,$_.Seconds})
		Write-Output $([pscustomobject]@{
			TestName    = $TestName
			TestGroup   = $TestGroup
			TestData    = $tempdata
			Description = $Description
			Status      = $stat
			Message     = $msg
			RunTime     = $rt
			Credential  = $(if($ScriptParams.Credential){$($ScriptParams.Credential).UserName} else { $env:USERNAME })
		})
	}
}
