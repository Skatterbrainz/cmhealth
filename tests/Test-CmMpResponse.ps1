function Test-CmMpResponse {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Test-CmMpResponse",
		[parameter()][string] $TestGroup = "configuration",
		[parameter()][string] $Description = "Validate MP web service reponse",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat = "PASS"
		$msg  = "No issues found"
		$Server = $($env:COMPUTERNAME).ToUpper()
		$URL1 = "http://$Server/sms_mp/.sms_aut?mpcert"
		$URL2 = "http://$Server/sms_mp/.sms_aut?mplist"
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
				$stat = "FAIL"
				$msg = "Invalid web response"
			}
		}
		catch {
			$MpcertStatus =  $_.Exception.Response.StatusCode
			$MpcertStatusCode = ( $_.Exception.Response.StatusCode -as [int])
			$MplisttStatus =  $_.Exception.Response.StatusCode
			$MplisttStatusCode = ( $_.Exception.Response.StatusCode -as [int])
			$stat = "ERROR"
			$msg = "Response: MPCERT $($Mpcertstatus) $($MpcertStatusCode) / MPLIST $($MplisttStatus) $($MplisttStatusCode)"
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
