function Test-CmClientOldVersion {
	[CmdletBinding()]
	[OutputType()]
	param (
		[parameter()][string] $TestName = "Old Client Versions",
		[parameter()][string] $TestGroup = "operation",
		[parameter()][string] $TestCategory = "CM",
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
sys.Client_Version0 as ClientVersion,
fcm.Domain,
sys.User_Name0 as UserName,
fcm.SiteCode,
st.Version as SiteVersion 
FROM v_FullCollectionMembership_Valid fcm
INNER JOIN v_R_System_Valid sys ON fcm.ResourceID = sys.ResourceID
INNER JOIN v_Site st ON st.SiteCode = fcm.SiteCode
WHERE fcm.CollectionID = 'SMS00001' AND sys.Client_Version0 < st.Version"
		$res = Get-CmSqlQueryResult -Query $query -Params $ScriptParams
		$siteversion = $res.SiteVersion
		if ($res.Count -gt 0) {
			$stat = $except
			$msg  = "$($res.Count) devices have a client installed older than site version: $($siteversion)"
			Write-Log -Message $msg
			$res | Foreach-Object {
				$tempdata.Add(
					[pscustomobject]@{
						ComputerName = $($_.Name)
						SiteCode     = $($_.SiteCode)
						Version      = $($_.ClientVersion)
						SiteVersion  = $($_.SiteVersion)
						UserName     = $($_.UserName)
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
