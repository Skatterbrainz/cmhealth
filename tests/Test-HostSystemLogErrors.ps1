function Test-HostSystemLogErrors {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "System Event Log Errors",
		[parameter()][string] $TestGroup = "operation",
		[parameter()][string] $Description = "Check for recent System log errors and warnings",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		$startTime = (Get-Date)
		[int] $MaxHours = 24
		#[int]$Setting = Get-CmHealthDefaultValue -KeySet "keygroup:keyname" -DataSet $CmHealthConfig
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat   = "PASS" # do not change this
		$except = "WARNING"
		$msg    = "No issues found" # do not change this either
		$query = @"
<QueryList>
  <Query Id="0" Path="System">
    <Select Path="System">*[System[(Level=2 or Level=3) and TimeCreated[timediff(@SystemTime) &lt;= 86400000]]]</Select>
  </Query>
</QueryList>
"@
		if ($ScriptParams.ComputerName -ne $env:COMPUTERNAME) {
			if ($ScriptParams.Credential) {
				$res = @(Get-WinEvent -LogName System -FilterXPath $query -ComputerName $ScriptParams.ComputerName -Credential $ScriptParams.Credential -ErrorAction SilentlyContinue)
			} else {
				$res = @(Get-WinEvent -LogName System -FilterXPath $query -ComputerName $ScriptParams.ComputerName -ErrorAction SilentlyContinue)
			}
		} else {
			$res = @(Get-WinEvent -LogName System -FilterXPath $query -ErrorAction SilentlyContinue)
		}
		$vwarnings = $res | Where-Object {$_.LevelDisplayName -eq 'Warning'}
		$verrors   = $res | Where-Object {$_.LevelDisplayName -eq 'Error'}
		if ($verrors.Count -gt 0) {
			$stat = $except
			$msg  = "$($verrors.Count) errors have occurred in the System log in the past $MaxHours hours"
		} else {
			if ($vwarnings.Count -gt 0) {
				$stat = $except
				$msg  = "$($vwarnings.Count) warnings have occurred in the System log in the past $MaxHours hours"
			}
		}
		$tempdata.Add(
			[pscustomobject]@{
				Errors = $($verrors.Count)
				Warnings = $($vwarnings.Count)
			}
		)
	}
	catch {
		$stat = 'ERROR'
		$msg = $_.Exception.Message -join ';'
	}
	finally {
		$rt = Get-RunTime -BaseTime $startTime
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
