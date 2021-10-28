function Test-CmSiteStatusMessages {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Site Status Messages",
		[parameter()][string] $TestGroup = "operation",
		[parameter()][string] $Description = "Site status messages with recent errors",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		$startTime = (Get-Date)
		#[int]$Setting = Get-CmHealthDefaultValue -KeySet "keygroup:keyname" -DataSet $CmHealthConfig
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat   = "PASS" # do not change this
		$except = "WARNING" # or "FAIL"
		$msg    = "No issues found" # do not change this either
		$res = Get-SiteStatusMessages -Params $ScriptParams
		$xcount = ($res | Where-Object {$_.Severity -in ('Error','Warning')}).Count
		if ($xcount -gt 0) {
			$stat = $except
			$msg = "$xcount status message with ERROR or WARNING were returned"
			$res | Foreach-Object { $tempdata.Add( $_ ) }
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