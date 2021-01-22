function Test-HostRestarts {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Test-HostRestarts",
		[parameter()][string] $TestGroup = "operation",
		[parameter()][string] $Description = "Assess unplanned host system restarts",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		#[int]$Setting = Get-CmHealthDefaultValue -KeySet "keygroup:keyname" -DataSet $CmHealthConfig
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat = "PASS" # do not change this
		$msg  = "No issues found" # do not change this either
		$query = @"
<QueryList>
  <Query Id="0" Path="System">
    <Select Path="System">*[System[Provider[@Name='Microsoft-Windows-Kernel-Power'] and (EventID=41) and TimeCreated[timediff(@SystemTime) &lt;= 604800000]]]</Select>
  </Query>
</QueryList>
"@
		if ($ScriptParams.ComputerName -ne $env:COMPUTERNAME) {
			Write-Verbose "running on $($ScriptParams.ComputerName)"
			if ($null -ne $ScriptParams.Credential) {
				Write-Verbose "credential was provided"
				$res = Get-WinEvent -LogName "System" -FilterXPath $query -ComputerName $ScriptParams.ComputerName -Credential $ScriptParams.Credential -ErrorAction SilentlyContinue
			} else {
				$res = Get-WinEvent -LogName "System" -FilterXPath $query -ComputerName $ScriptParams.ComputerName -ErrorAction SilentlyContinue
			}
		} else {
			Write-Verbose "running on localhost"
			$res = Get-WinEvent -LogName "System" -FilterXPath $query -ErrorAction SilentlyContinue
		}
		if ($res.Count -gt 0) {
			$stat = "WARNING" # or "FAIL"
			$msg  = "$($res.Count) items found"
			$winevent = @{TimeCreated = $_.TimeCreated; Computer = $_.MachineName; Message = $_.Message}
			$res | Foreach-Object {$tempdata.Add($winevent)}
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
