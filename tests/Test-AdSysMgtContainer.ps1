function Test-AdSysMgtContainer {
	[CmdletBinding()]
	[OutputType()]
	param (
		[parameter()][string] $TestName = "Active Directory System Management Container",
		[parameter()][string] $TestGroup = "configuration",
		[parameter()][string] $TestCategory = "AD",
		[parameter()][string] $Description = "Verify System Management container has been created with delegated permissions",
		[parameter()][hashtable] $ScriptParams
	)
	$startTime = (Get-Date)
	$stat = "PASS"
	$except = "FAIL"
	$msg = "No issues found"
	try {
		Write-Log -Message "Searching for AD container: System Management"
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$res = Get-ADSIObject -Identity "System Management" -ErrorAction SilentlyContinue
		if ($null -eq $res) {
			$stat = $except
			$msg = "System Management container was not found in the current/active domain"
		}
	}
	catch {
		$stat = "ERROR"
		$msg  = $_.Exception.Message -join ';'
	}
	finally {
		Set-CmhOutputData
	}
}