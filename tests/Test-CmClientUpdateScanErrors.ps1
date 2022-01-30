function Test-CmClientUpdateScanErrors {
	[CmdletBinding()]
	[OutputType()]
	param (
		[parameter()][string] $TestName = "Client Update Scan Errors",
		[parameter()][string] $TestGroup = "operation",
		[parameter()][string] $TestCategory = "CM",
		[parameter()][string] $Description = "Check for clients with software update scan errors",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		$startTime = (Get-Date)
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat   = "PASS" # do not change this
		$except = "WARNING"
		$msg    = "No issues found" # do not change this either
		$query = "SELECT DISTINCT
rsys.Name0 as MachineName,
rsys.Client_Version0 as SMSClientVersion,
uss.LastWUAVersion as WUAVersion,
rsys.User_Name0 as LastLoggedOnUser,
uss.LastStatusMessageID & 0x0000FFFF as ErrorStatusID,
uss.LastErrorCode as LastErrorCode,
LastScanTime,
fcm.SiteCode
from v_UpdateScanStatus uss with (NOLOCK)
join v_ClientCollectionMembers ccm with (NOLOCK) on uss.ResourceID = ccm.ResourceID
join v_SoftwareUpdateSource sus with (NOLOCK) on sus.UpdateSource_ID = uss.UpdateSource_ID
join v_R_System rsys with (NOLOCK) on rsys.ResourceID = uss.ResourceID
join v_FullCollectionMembership_Valid fcm with (NOLOCK) on uss.ResourceID = fcm.ResourceID
where uss.LastStatusMessageID <> 0 and fcm.CollectionID = 'SMS00001'
ORDER BY rsys.Name0"
		$res = Get-CmSqlQueryResult -Query $query -Params $ScriptParams
		if ($res.Count -gt 0) {
			$stat = $except
			$msg  = "$($res.Count) clients with update scan errors found"
			Write-Log -Message $msg
			$res | Foreach-Object {
				$tempdata.Add(
					[pscustomobject]@{
						ComputerName = $_.MachineName
						Client     = $_.SMSClientVersion
						WUAVersion = $_.WUAVersion
						LastUser   = $_.LastLoggedOnUser
						ErrorCode  = $_.LastErrorCode
						HexCode    = Convert-DecErrToHex -DecimalNumber $($_.LastErrorCode)
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
