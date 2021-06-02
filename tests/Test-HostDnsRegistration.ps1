function Test-HostDnsRegistration {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Validate Host DNS A-record Registration",
		[parameter()][string] $TestGroup = "configuration",
		[parameter()][string] $Description = "Validate Host DNS A-record Registration",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		$startTime = (Get-Date)
		#[int]$Setting = Get-CmHealthDefaultValue -KeySet "keygroup:keyname" -DataSet $CmHealthConfig
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat   = "PASS" # do not change this
		$except = "WARNING" # or "FAIL"
		$msg    = "No issues found" # do not change this either
		if ($ScriptParams.ComputerName -eq "localhost") {
			$name = $(Get-WmiObject win32_computersystem).DNSHostName+"."+$(Get-WmiObject win32_computersystem).Domain
		} else {
			$name = $ScriptParams.ComputerName
		}
		[array]$res = $(Resolve-DnsName -Name $name -Type A)
		if ($res.Count -gt 1) {
			$stat = $except
			$msg  = "$($res.Count) items returned"
		}
		$res | Foreach-Object {
			$tempdata.Add(
				[pscustomobject]@{
					HostName = $_.Name
					RecordType = $_.Type
					TTL = $_.TTL
					IPAddress = $_.IPAddress
				}
			)
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
			RunTime     = $(Get-RunTime -BaseTime $startTime)
			Credential  = $(if($ScriptParams.Credential){$($ScriptParams.Credential).UserName} else { $env:USERNAME })
		})
	}
}
