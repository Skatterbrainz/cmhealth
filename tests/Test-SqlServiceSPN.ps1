function Test-SqlServicesSPN {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "SQL SPN Registration",
		[parameter()][string] $TestGroup = "configuration",
		[parameter()][string] $Description = "Verify SQL instance Service Principal Name registration",
		[parameter()][bool] $Remediate = $False,
		[parameter()][string] $SqlInstance = "localhost",
		[parameter()][string] $Database = ""
	)
	try {
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat = "PASS"
		<# 
		DELETE THIS COMMENT BLOCK WHEN FINISHED:
		perform test and return result as an object...
			$stat = 'PASS' or 'FAIL'
			$msg = "whatever you want to provide"
		#>
		if (-not ($spn = Get-DbaSpn -ComputerName $SqlInstance -ErrorAction SilentlyContinue)) {
			if ($Remediate -eq $True) {
				
				# more work needed here!

				$stat = 'REMEDIATED'
				$msg  = 'SPN has been successfully registered'
			}
			else {
				$stat = 'FAIL'
				$msg  = 'SPN is not currently registered'
			}
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
		})
	}
}
