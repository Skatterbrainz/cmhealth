function Test-SqlDbDiskAlignment {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "SQL Server Disk Alignment Status",
		[parameter()][string] $TestGroup = "configuration",
		[parameter()][string] $Description = "Validate disk alignment with SQL recommended practices",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		$startTime = (Get-Date)
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat   = "PASS"
		$except = "WARNING"
		$msg    = "No issues found"
		if ($null -ne $ScriptParams.Credential) {
			$da = Test-DbaDiskAlignment -ComputerName $ScriptParams.SqlInstance -SqlCredential $ScriptParams.Credential
		} else {
			$da = Test-DbaDiskAlignment -ComputerName $ScriptParams.SqlInstance
		}
		if ($da -eq $false) {
			$stat = $except
			$msg  = "One or more disks are not aligned using recommended practices"
		}
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
