function Test-HostAntiVirus {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Test-HostAntiVirus",
		[parameter()][string] $TestGroup = "configuration",
		[parameter()][string] $Description = "Check for third-party antivirus software installations",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		#[int]$Setting = Get-CmHealthDefaultValue -KeySet "keygroup:keyname" -DataSet $CmHealthConfig
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat = "PASS" # do not change this
		$msg  = "No issues found" # do not change this either

		if ($ScriptParams.ComputerName -ne $env:COMPUTERNAME) {
			if ($ScriptParams.Credential) {
				$cs = New-CimSession -Credential $ScriptParams.Credential -Authentication Negotiate -ComputerName $ScriptParams.ComputerName
				$apps = @(Get-CimInstance -CimSession $cs -ClassName "Win32_Product" -Namespace "root\cimv2" -Filter "Name like '%antivirus%'")
			} else {
				$apps = @(Get-CimInstance -ComputerName $ScriptParams.ComputerName -ClassName "Win32_Product" -Namespace "root\cimv2" -Filter "Name like '%antivirus%'")
			}
		} else {
			$apps = @(Get-CimInstance -ClassName "Win32_Product" -Namespace "root\cimv2" -Filter "Name like '%antivirus%'" )
		}
		$apps | Foreach-Object {
			$tempdata.Add(
				[pscustomobject]@{
					Name        = $_.Name 
					Vendor      = $_.Vendor 
					Version     = $_.Version 
					DisplayName = $_.Caption
				}
			)
		}
		if ($apps.Count -gt 0) {
			$stat = "WARNING" # or "FAIL"
			$services | Foreach-Object {$tempdata.Add($_.Name)}
			$msg = "Third-party antivirus products were found"
			$services | Foreach-Object {$tempdata.Add($_.Name)}
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
