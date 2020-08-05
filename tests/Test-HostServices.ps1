function Test-HostServices {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Test-HostServices",
		[parameter()][string] $TestGroup = "operation",
		[parameter()][string] $Description = "Verify auto-start services are running",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat = "PASS"
		$msg  = "No issues found"
		if (![string]::IsNullOrEmpty($ScriptParams.ComputerName) -and $Script.Params.ComputerName -ne $env:COMPUTERNAME) {
			$cs = New-CimSession -Credential $ScriptParams.Credential -Authentication Negotiate -ComputerName $ScriptParams.ComputerName
			$services = @(Get-CimInstance -CimSession $cs -ClassName Win32_Service | Where-Object {$_.StartMode -match 'auto' -and $_.State -ne 'Running'})
			$cs.Close()
			$cs = $null
		} else {
			$services = @(Get-CimInstance -ClassName Win32_Service | Where-Object {$_.StartMode -match 'auto' -and $_.State -ne 'Running'})
		}
		if ($services.Count -gt 0) {
			$stat = "FAIL"
			$services | Foreach-Object {$tempdata.Add($_.Name)}
			$msg = "$($services.Count) stopped services: $($services.Name -join ',')"
		}
	}
	catch {
		$stat = 'ERROR'
		$msg = $_.Exception.Message -join ';'
	}
	finally {
		if ($cs) { $cs.Close(); $cs = $null }
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
