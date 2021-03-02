function Test-SqlServerVersion {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Check SQL Server Version",
		[parameter()][string] $TestGroup = "configuration",
		[parameter()][string] $Description = "Check if SQL Server is a supported version",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		$startTime = (Get-Date)
		#[int]$Setting = Get-CmHealthDefaultValue -KeySet "keygroup:keyname" -DataSet $CmHealthConfig
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat    = "PASS" # do not change this
		$except  = "FAIL" # or "WARNING"
		$msg     = "No issues found" # do not change this either
		$res     = Get-DbaBuildReference -SqlInstance $ScriptParams.SqlInstance
		$fname   = "SQL Server $($res.NameLevel) $($res.SPLevel) $($res.CULevel)"
		$expdate = $res.SupportedUntil
		$supported = $(New-TimeSpan -Start (Get-Date) -End $expdate).TotalDays
		if ($supported -le 0) {
			$stat = $except
			$msg  = "FAIL! $fname support has expired!"
		} elseif ($supported -le 30) {
			Write-Verbose "Warning! Support will end in $supported days"
			$stat = "WARNING"
			$msg  = "$fname support is will expire within $supported days"
		} else {
			Write-Verbose "$fname is supported until $($res.SupportedUntil)"
		}
		$tempdata.Add(
			[pscustomobject]@{
				SqlInstance = $res.SqlInstance
				SqlVersion  = $fname
				Build       = $res.Build
				NameLevel   = $res.NameLevel
				SupportEnds = $res.SupportedUntil
			}
		)
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
