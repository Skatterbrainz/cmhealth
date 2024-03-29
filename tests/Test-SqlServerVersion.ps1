function Test-SqlServerVersion {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Check SQL Server Version",
		[parameter()][string] $TestGroup = "configuration",
		[parameter()][string] $TestCategory = "SQL",
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
		$res     = Get-DbaBuildReference -SqlInstance $ScriptParams.SqlInstance -Update
		$fname   = "SQL Server $($res.NameLevel) $($res.SPLevel) $($res.CULevel)"
		$expdate = $res.SupportedUntil
		$supported = $(New-TimeSpan -Start (Get-Date) -End $expdate).TotalDays
		if ($supported -le 0) {
			$stat = $except
			$msg  = "FAIL! $fname support has expired!"
		} elseif ($supported -le 30) {
			Write-Log -Message "Warning! Support will end in $supported days"
			$stat = "WARNING"
			$msg  = "$fname support is will expire within $supported days"
		} else {
			$msg = "$fname support is supported until $($res.SupportedUntil)"
			Write-Log -Message "$fname is supported until $($res.SupportedUntil)"
		}
		$tempdata.Add(
			[pscustomobject]@{
				SqlInstance = $res.SqlInstance
				SqlVersion  = $fname
				Build       = $res.Build
				NameLevel   = $res.NameLevel
				SupportEnds = $res.SupportedUntil
				Message     = $msg
			}
		)
	}
	catch {
		$stat = 'ERROR'
		$msg = $_.Exception.Message -join ';'
	}
	finally {
		Set-CmhOutputData
	}
}
