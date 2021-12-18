function Test-HostAppLogErrors {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Application Event Log Errors",
		[parameter()][string] $TestGroup = "operation",
		[parameter()][string] $TestCategory = "HOST",
		[parameter()][string] $Description = "Check for recent Application log errors and warnings",
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
  <Query Id="0" Path="Application">
    <Select Path="Application">*[System[(Level=1  or Level=2 or Level=3) and TimeCreated[timediff(@SystemTime) &lt;= 86400000]]]</Select>
  </Query>
</QueryList>
"@
		[array]$computers = $ScriptParams.ComputerName
		if ($ScriptParams.ComputerName -ne $ScriptParams.SqlInstance) {
			$computers += $ScriptParams.SqlInstance
		}
		$count1 = 0 # errors
		$count2 = 0 # warnings
		foreach ($computer in $computers) {
			Write-Log -Message "computer: $computer"
			if ($computer -ne $env:COMPUTERNAME) {
				if ($ScriptParams.Credential) {
					$res = @(Get-WinEvent -LogName Application -FilterXPath $query -ComputerName $computer -Credential $ScriptParams.Credential -ErrorAction SilentlyContinue)
				} else {
					$res = @(Get-WinEvent -LogName Application -FilterXPath $query -ComputerName $computer -ErrorAction SilentlyContinue)
				}
			} else {
				$computer = $env:COMPUTERNAME
				$res = @(Get-WinEvent -LogName Application -FilterXPath $query -ErrorAction SilentlyContinue)
			}
			$vwarnings = $res | Where-Object {$_.LevelDisplayName -eq 'Warning'}
			$verrors   = $res | Where-Object {$_.LevelDisplayName -eq 'Error'}
			$count1 += $verrors.Count
			$count2 += $vwarnings.Count
			if ($vwarnings.Count -gt 0) {
				$stat = $except
				$vwarnings | ForEach-Object {
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
			if ($verrors.Count -gt 0) {
				$stat = $except
				$res | Foreach-Object {
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
		$msg  = "$($count1) Errors and $($count2) Warnings occurred in the Application log within the past $MaxHours hours"
	}
	catch {
		$stat = 'ERROR'
		$msg = $_.Exception.Message -join ';'
	}
	finally {
		$([pscustomobject]@{
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
