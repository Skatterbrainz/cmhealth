function Test-HostSystemLogErrors {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "System Event Log Errors",
		[parameter()][string] $TestGroup = "operation",
		[parameter()][string] $TestCategory = "HOST",
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
		[array]$computers = $ScriptParams.ComputerName
		if ($ScriptParams.ComputerName -ne $ScriptParams.SqlInstance) {
			$computers += $ScriptParams.SqlInstance
		}
		foreach ($computer in $computers) {
			Write-Log -Message "computer: $computer"
			if ($computer -ne $env:COMPUTERNAME) {
				if ($ScriptParams.Credential) {
					$res = @(Get-WinEvent -LogName System -FilterXPath $query -ComputerName $computer -Credential $ScriptParams.Credential -ErrorAction SilentlyContinue)
				} else {
					$res = @(Get-WinEvent -LogName System -FilterXPath $query -ComputerName $computer -ErrorAction SilentlyContinue)
				}
			} else {
				$computer = $env:COMPUTERNAME
				$res = @(Get-WinEvent -LogName System -FilterXPath $query -ErrorAction SilentlyContinue)
			}
			$vwarnings = $res | Where-Object {$_.LevelDisplayName -eq 'Warning'}
			$verrors   = $res | Where-Object {$_.LevelDisplayName -eq 'Error'}
			if (($verrors.Count -gt 0) -or ($vwarnings.Count -gt 0)) {
				$msg  = "$($verrors.Count) Errors and $($vwarnings.Count) Warnings occurred in the System log within the past $MaxHours hours"
				$stat = $except
				$res | Where-Object {$_.LevelDisplayName -in ('Warning','Error')} | Foreach-Object {
					$tempdata.Add(
						[pscustomobject]@{
							Computer = $_.MachineName
							Level = $_.LevelDisplayName
							ID = $_.Id
							Provider = $_.ProviderName
							Log = $_.LogName
							TimeCreated = $_.TimeCreated
							Message = $_.Message
						}
					)
				}
			}
		} # foreach
	}
	catch {
		$stat = 'ERROR'
		$msg = $_.Exception.Message -join ';'
	}
	finally {
		Write-Output $([pscustomobject]@{
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
}
