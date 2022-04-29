function Test-CmSiteStatusMessages {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Site Status Messages",
		[parameter()][string] $TestGroup = "operation",
		[parameter()][string] $TestCategory = "CM",
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
		$count1 = $($res | Where-Object {$_.Severity -eq 'Error'}).Count
		$count2 = $($res | Where-Object {$_.Severity -eq 'Warning'}).Count
		#$xcount = ($res | Where-Object {$_.Severity -in ('Error','Warning')}).Count
		if ($($count1+$count2) -gt 0) {
			$stat = $except
			$msg = "Site status message counts: Error=$($count1), Warning=$($count2). Total=$($count1+$count2). Review Monitoring > System Status for more details"
			$res | Foreach-Object { $tempdata.Add( $_ ) }
		}
	}
	catch {
		$stat = 'ERROR'
		$msg = $_.Exception.Message -join ';'
	}
	finally {
		Set-CmhOutputData
	}
}
