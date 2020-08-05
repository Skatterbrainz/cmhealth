function Test-CmClientOldUpdateAgent {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Test-CmClientOldUpdateAgent",
		[parameter()][string] $TestGroup = "configuration",
		[parameter()][string] $Description = "Clients with old Windows Update agent",
		[parameter()][hashtable] $ScriptParams
	)
	# reference: https://support.microsoft.com/en-us/help/949104/how-to-update-the-windows-update-agent-to-the-latest-version#:~:text=9600.16422.-,The%20latest%20version%20of%20the%20Windows%20Update%20Agent%20for%20Windows,7600.256.
	try {
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat = "PASS" # do not change this
		$msg  = "No issues found" # do not change this either
		$query = "SELECT DISTINCT 
	rsys.Netbios_Name0 AS MachineName, 
	rsys.Client_Version0,
	uss.LastWUAVersion,
	fcm.SiteCode
FROM v_UpdateScanStatus uss WITH (NOLOCK) 
JOIN v_ClientCollectionMembers ccm WITH (NOLOCK) ON uss.ResourceID = ccm.ResourceID 
JOIN v_SoftwareUpdateSource sus WITH (NOLOCK) ON sus.UpdateSource_ID = uss.UpdateSource_ID 
JOIN v_R_System_Valid rsys WITH (NOLOCK) ON rsys.ResourceID = uss.ResourceID 
JOIN v_FullCollectionMembership_VaLID fcm WITH (NOLOCK) ON uss.ResourceID = fcm.ResourceID AND fcm.CollectionID = 'SMS00001'
INNER JOIN v_GS_OPERATING_SYSTEM ops ON rsys.ResourceID = ops.ResourceID
WHERE ops.Version0 < '10.0' AND uss.LastWUAVersion < '7.6.7600.256'

UNION

SELECT DISTINCT 
	rsys.Netbios_Name0 as MachineName, 
	rsys.Client_Version0,
	uss.LastWUAVersion,
	fcm.SiteCode
FROM v_UpdateScanStatus uss WITH (NOLOCK) 
JOIN v_ClientCollectionMembers ccm WITH (NOLOCK) ON uss.ResourceID = ccm.ResourceID 
JOIN v_SoftwareUpdateSource sus WITH (NOLOCK) ON sus.UpdateSource_ID = uss.UpdateSource_ID 
JOIN v_R_System_Valid rsys WITH (NOLOCK) ON rsys.ResourceID = uss.ResourceID 
JOIN v_FullCollectionMembership_VaLID fcm WITH (NOLOCK) ON uss.ResourceID = fcm.ResourceID AND fcm.CollectionID = 'SMS00001'
INNER JOIN v_GS_OPERATING_SYSTEM ops ON rsys.ResourceID = ops.ResourceID
WHERE ops.Version0 like '6.2.%' AND uss.LastWUAVersion < '7.8.9200.16693'

UNION

SELECT DISTINCT 
	rsys.Netbios_Name0 as MachineName, 
	rsys.Client_Version0,
	uss.LastWUAVersion,
	fcm.SiteCode
FROM v_UpdateScanStatus uss WITH (NOLOCK) 
JOIN v_ClientCollectionMembers ccm WITH (NOLOCK) ON uss.ResourceID = ccm.ResourceID 
JOIN v_SoftwareUpdateSource sus WITH (NOLOCK) ON sus.UpdateSource_ID = uss.UpdateSource_ID 
JOIN v_R_System_Valid rsys WITH (NOLOCK) ON rsys.ResourceID = uss.ResourceID 
JOIN v_FullCollectionMembership_VaLID fcm WITH (NOLOCK) ON uss.ResourceID = fcm.ResourceID AND fcm.CollectionID = 'SMS00001'
INNER JOIN v_GS_OPERATING_SYSTEM ops ON rsys.ResourceID = ops.ResourceID
WHERE ops.Version0 > '6.2' AND uss.LastWUAVersion < '7.9.9600.16422'"
		$res = @(Invoke-DbaQuery -SqlInstance $ScriptParams.SqlInstance -Database $ScriptParams.Database -Query $query)
		if ($null -ne $res -and $res.Count -gt 0) {
			$stat = "WARNING" # or "FAIL"
			$msg  = "$($res.Count) items found: $($res.MachineName -join ',')"
			$res | Foreach-Object {$tempdata.Add(@($_.MachineName, $_.LastWUAVersion))}
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
