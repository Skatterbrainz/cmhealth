function Test-CmComponentErrorSolutions {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Test-CmComponentErrorSolutions",
		[parameter()][string] $TestGroup = "operation",
		[parameter()][string] $Description = "Get component error solutions",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat = "PASS" # do not change this
		$msg  = "No issues found" # do not change this either
		$query = "SELECT DISTINCT 
stat.Component, stat.MessageID, stat.MessageID AS Value
FROM vStatusMessages AS stat where
stat.Severity IN (-1073741824, -2147483648)
AND stat.Component NOT IN ('Advanced Client', 'Windows Installer SourceList Update Agent', 
'Desired Configuration Management', 'Software Updates Scan Agent', 'File Collection Agent', 
'Hardware Inventory Agent', 'Software Distribution', 'Software Inventory Agent')
AND stat.Time >= DATEADD(dd,-CONVERT(INT,$($ScriptParams.DaysBack)),GETDATE())"
		if ($ScriptParams.Credential) {
			$res = @(Invoke-DbaQuery -SqlInstance $ScriptParams.SqlInstance -Database $ScriptParams.Database -Query $query -SqlCredential $ScriptParams.Credential)
		} else {
			$res = @(Invoke-DbaQuery -SqlInstance $ScriptParams.SqlInstance -Database $ScriptParams.Database -Query $query)
		}
		if ($null -ne $res -and $res.Count -gt 0) {
			$stat = "WARNING" # or "FAIL"
			$msg  = "$($res.Count) items found: $($res.Name -join ',')"
			#$res | Foreach-Object {$tempdata.Add($_.Name)}
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
