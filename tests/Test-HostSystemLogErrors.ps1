function Test-HostSystemLogErrors {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Test-HostSystemLogErrors",
		[parameter()][string] $TestGroup = "operational",
		[parameter()][string] $Description = "Check for recent System log errors and warnings",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		[int] $MaxHours = 24 
		#[int]$Setting = Get-CmHealthDefaultValue -KeySet "keygroup:keyname" -DataSet $CmHealthConfig
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat = "PASS" # do not change this
		$msg  = "No issues found" # do not change this either

		$query = '<QueryList>
  <Query Id="0" Path="System">
    <Select Path="System">*[System[(Level=2 or Level=3) and TimeCreated[timediff(@SystemTime) &lt;= 86400000]]]</Select>
  </Query>
</QueryList>'

		if ($ScriptParams.ComputerName -ne $env:COMPUTERNAME) {
			if ($ScriptParams.Credential) {
				$res = @(Get-WinEvent -LogName System -FilterXPath $query -ComputerName $ScriptParams.ComputerName -Credential $ScriptParams.Credential -ErrorAction Stop)
			} else {
				$res = @(Get-WinEvent -LogName System -FilterXPath $query -ComputerName $ScriptParams.ComputerName -ErrorAction Stop)
			}
		} else {
			$res = @(Get-WinEvent -LogName System -FilterXPath $query -ErrorAction Stop)
		}

		$vwarnings = $res | Where-Object {$_.LevelDisplayName -eq 'Warning'}
		$verrors   = $res | Where-Object {$_.LevelDisplayName -eq 'Error'}

		if ($verrors.Count -gt 0) {
			$stat = 'WARNING'
			$msg  = "$($verrors.Count) errors have occurred in the System log in the past $MaxHours hours"
		} else {
			if ($vwarnings.Count -gt 0) {
				$stat = 'WARNING'
				$msg  = "$($vwarnings.Count) warnings have occurred in the System log in the past $MaxHours hours"
			}
		}
		$tempdata.Add( "Errors=$($verrors.Count), Warnings=$($vwarnings.Count)")

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
