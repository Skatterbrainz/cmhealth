function Test-SqlDbDiskAlignment {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Test-SqlDbDiskAlignment",
		[parameter()][string] $TestGroup = "configuration",
		[parameter()][string] $Description = "Validate disk alignment with SQL recommended practices",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat = "PASS"
		$msg  = "No issues found"
		if ($ScriptParams.Credential) {
			$da = Test-DbaDiskAlignment -ComputerName $ScriptParams.SqlInstance -SqlCredential $ScriptParams.Credential
		} else {
			$da = Test-DbaDiskAlignment -ComputerName $ScriptParams.SqlInstance
		}
		if ($da -eq $false) {
			$stat = "FAIL"
			$msg  = "One or more disks are not aligned using recommended practices"
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
