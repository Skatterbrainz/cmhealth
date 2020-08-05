function Test-HostInstalledSoftware {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Test-HostInstalledSoftware",
		[parameter()][string] $TestGroup = "configuration",
		[parameter()][string] $Description = "Check for excessive junk installed on site server",
		[parameter()][hashtable] $ScriptParams
	)
	[int]$MaxProducts = 40
	try {
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat = "PASS" # do not change this
		$msg  = "No issues found" # do not change this either
		if ($ScriptParams.ComputerName -ne $env:COMPUTERNAME) {
			if ($ScriptParams.Credential) {
				$cs = New-CimSession -ComputerName $ScriptParams.ComputerName -Credential $ScriptParams.Credential -Authentication Negotiate -ErrorAction Stop
				$res = @(Get-CimInstance -ClassName Win32_Product -CimSession $cs -ErrorAction Stop | Select-Object Name,Version,Vendor,ProductCode)
			} else {
				$res = @(Get-CimInstance -ClassName Win32_Product -ComputerName $ScriptParams.ComputerName -ErrorAction Stop | Select-Object Name,Version,Vendor,ProductCode)
			}
		} else {
			$res = @(Get-CimInstance -ClassName Win32_Product -ErrorAction Stop | Select-Object Name,Version,Vendor,ProductCode)
		}
		if ($res.Count -gt $MaxProducts) {
			$stat = "WARNING" # or "FAIL"
			$msg  = "$($res.Count) items found. See TestData for item details"
			$res | Foreach-Object {$tempdata.Add(@($_.Name,$_.Version,$_.Vendor,$_.ProductCode))}
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
