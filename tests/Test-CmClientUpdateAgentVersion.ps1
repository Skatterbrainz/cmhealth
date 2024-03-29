function Test-CmClientUpdateAgentVersion {
	[CmdletBinding()]
	[OutputType()]
	param (
		[parameter()][string] $TestName = "Clients with Old Windows Update Agent",
		[parameter()][string] $TestGroup = "configuration",
		[parameter()][string] $TestCategory = "CM",
		[parameter()][string] $Description = "Clients with old Windows Update agent",
		[parameter()][hashtable] $ScriptParams
	)
	# reference: https://support.microsoft.com/en-us/help/949104/how-to-update-the-windows-update-agent-to-the-latest-version#:~:text=9600.16422.-,The%20latest%20version%20of%20the%20Windows%20Update%20Agent%20for%20Windows,7600.256.
	try {
		$startTime = (Get-Date)
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat   = "PASS" # do not change this
		$except = "WARNING"
		$msg    = "No issues found" # do not change this either
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
		$res = Get-CmSqlQueryResult -Query $query -Params $ScriptParams
		if ($res.Count -gt 0) {
			$stat = $except
			$msg  = "$($res.Count) items found: $($res.MachineName -join ',')"
			$res | Foreach-Object {
				$tempdata.Add(
					[pscustomobject]@{
						Machine = $_.MachineName
						SiteCode = $_.SiteCode
						WUAVersion = $_.LastWUAVersion
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
		Set-CmhOutputData
	}
}
