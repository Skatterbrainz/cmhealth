function Test-CmMpResponse {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Management Point Response",
		[parameter()][string] $TestGroup = "configuration",
		[parameter()][string] $TestCategory = "CM",
		[parameter()][string] $Description = "Validate MP web service reponse",
		[parameter()][hashtable] $ScriptParams
	)
	$startTime = (Get-Date)
	[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
	$stat   = "PASS"
	$except = "FAIL"
	$msg    = "No issues found"
	$query = "SELECT srs.ServerName,srs.SiteCode,vs.SiteName,vst.AD_Site_Name0 as ADSite,
vs.ReportingSiteCode as Parent,vs.Installdir
FROM v_SystemResourceList as srs
LEFT JOIN v_site vs on srs.ServerName = vs.ServerName
LEFT JOIN v_R_System_Valid vst on LEFT(srs.ServerName, CHARINDEX('.', srs.ServerName) - 1) = vst.Netbios_Name0
WHERE srs.RoleName = 'SMS Management Point'
ORDER BY srs.ServerName"
	$servers = Get-CmSqlQueryResult -Query $query -Params $ScriptParams
	foreach ($server in $servers.ServerName) {
		$URL1 = "http://$Server/sms_mp/.sms_aut?mpcert"
		$URL2 = "http://$Server/sms_mp/.sms_aut?mplist"
		Write-Log -Message "submitting mp requests: $URL1 $URL2"
		$WEBObject1 = [System.Net.WebRequest]::Create($URL1)
		$WEBObject2 = [System.Net.WebRequest]::Create($URL2)
		$WEBObject1.AuthenticationLevel = "None"
		$WEBObject2.AuthenticationLevel = "None"
		$WEBObject1.Timeout = 7000
		$WEBObject2.Timeout = 7000
		try {
			$WEBResponse1 = $WEBObject1.GetResponse()
			$MpcertStatus = $WEBResponse1.StatusCode
			$MpcertStatusCode = ($WEBResponse1.Statuscode -as [int])
			$WEBResponse1.Close()
			$WEBResponse2 = $WEBObject2.GetResponse()
			$MplistStatus = $WEBResponse2.StatusCode
			$MplistStatusCode = ($WEBResponse2.Statuscode -as [int])
			$WEBResponse2.Close()
			if (($MpcertStatusCode -ne "200") -or ($MplistStatusCode -ne "200")) {
				$stat = $except
				$msg = "Invalid web response"
			}
			$tempdata.Add(
				[pscustomobject]@{
					SiteServer = $server
					MPCertStatus = $MpcertStatusCode
					MPCertUrl = $URL1
					MPListStatus = $MplistStatusCode
					MPListUrl = $URL2
				}
			)
		}
		catch {
			$MpcertStatus =  $_.Exception.Response.StatusCode
			$MpcertStatusCode = ( $_.Exception.Response.StatusCode -as [int])
			$MplisttStatus =  $_.Exception.Response.StatusCode
			$MplisttStatusCode = ( $_.Exception.Response.StatusCode -as [int])
			$stat = "ERROR"
			$msg = "Response: MPCERT $($Mpcertstatus) $($MpcertStatusCode) / MPLIST $($MplisttStatus) $($MplisttStatusCode)"
		}		
	} # foreach

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
