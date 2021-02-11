function Test-HostServices {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Test-HostServices",
		[parameter()][string] $TestGroup = "operation",
		[parameter()][string] $Description = "Verify auto-start services are running",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		$startTime = (Get-Date)
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat   = "PASS"
		$except = "WARNING"
		$msg    = "No issues found"
		if ($ScriptParams.ComputerName -ne $env:COMPUTERNAME) {
			if ($ScriptParams.Credential) {
				$cs = New-CimSession -Credential $ScriptParams.Credential -Authentication Negotiate -ComputerName $ScriptParams.ComputerName
				$services = @(Get-CimInstance -CimSession $cs -ClassName Win32_Service | Where-Object {$_.StartMode -match 'auto' -and $_.State -ne 'Running'})
			} else {
				$services = @(Get-CimInstance -ComputerName $ScriptParams.ComputerName -ClassName Win32_Service | Where-Object {$_.StartMode -match 'auto' -and $_.State -ne 'Running'})
			}
		} else {
			$services = @(Get-CimInstance -ClassName Win32_Service | Where-Object {$_.StartMode -match 'auto' -and $_.State -ne 'Running'})
		}
		if ($services.Count -gt 0) {
			$stat = $except
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
