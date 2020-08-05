function Test-CmInvMaxMIFSize {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Test-CmInvMaxMIFSize",
		[parameter()][string] $TestGroup = "configuration",
		[parameter()][string] $Description = "Validate inventory loader maximum MIF file size setting",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat = "PASS" # do not change this
		$msg  = "No issues found" # do not change this either
		$MaxMIF = 52428800
		$res = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\SMS\COMPONENTS\SMS_INVENTORY_DATA_LOADER" -Name "Max MIF Size" | Select-Object -ExpandProperty "Max MIF Size")
		if ($res -lt $MaxMIF) {
			if ($ScriptParams.Remediate -eq $True) {
				Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\SMS\COMPONENTS\SMS_INVENTORY_DATA_LOADER" -Name 'Max MIF Size' -Value $MaxMIF -Force | Out-Null
				$stat = "REMEDIATED"
				$msg  = "Max MIF Size is now set to $MaxMIF"
			} else {
				$stat = "FAIL"
				$msg  = "Max MIF size is $res (hex) which should be 3200000 (hex) or $MaxMIF"
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
			Credential  = $(if($ScriptParams.Credential){$($ScriptParams.Credential).UserName} else { $env:USERNAME })
		})
	}
}
