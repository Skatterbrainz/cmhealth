function Test-SqlDbFileGrowth {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "SQL Database File Growth",
		[parameter()][string] $TestGroup = "configuration",
		[parameter()][string] $Description = "Validate SQL Database File Auto-Growth settings",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		$startTime = (Get-Date)
		Write-Warning "$TestName - THIS TEST IS NOT COMPLETE - PLEASE CONSIDER CONTRIBUTING?"
		$stat   = "PASS"
		$except = "WARNING"
		$msg    = "No issues found"
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		<#
		if ($ScriptParams.Credential) {
			$dbfiles = Get-DbaDbFile -SqlInstance $ScriptParams.SqlInstance -Database $ScriptParams.Database -SqlCredential $ScriptParams.Credential
		} else {
			$dbfiles = Get-DbaDbFile -SqlInstance $ScriptParams.SqlInstance -Database $ScriptParams.Database
		}
		$query = "select distinct Name from v_CombinedDeviceResources where (Name not like '%Unknown%') and (Name not like 'Provisioning Device%')"
		if ($null -ne $ScriptParams.Credential) {
			$clients = @(Invoke-DbaQuery -SqlInstance $ScriptParams.SqlInstance -Database $ScriptParams.Database -Query $query -SqlCredential $ScriptParams.Credential).Count
		} else {
			$clients = @(Invoke-DbaQuery -SqlInstance $ScriptParams.SqlInstance -Database $ScriptParams.Database -Query $query).Count
		}
		Write-Verbose "clients = $clients"
		switch ($ScriptParams.FileType) {
			'Database' {
				$files = $dbfiles | Where-Object {$_.TypeDescription -eq 'Rows'}
				$test1 = $files | Where-Object {$_.GrowthType -eq 'Percent' -and $_.Growth -ge 10}
				$test2 = $files | Where-Object {$_.GrowthType -eq '' -and $_.Growth -ge 256}

				# more work needed here!
			}
			'Log' {
				# more work needed here!
			}
		} # switch
		#>
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
