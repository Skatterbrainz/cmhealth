function Test-SqlServiceSPN {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Test-SqlServiceSPN",
		[parameter()][string] $TestGroup = "configuration",
		[parameter()][string] $Description = "Verify SQL instance Service Principal Name registration",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat = "PASS"
		$msg  = "No issues found"
		if ($ScriptParams.Credential) {
			$spns = Test-DbaSpn -ComputerName $ScriptParams.ComputerName -EnableException -Credential $ScriptParams.Credential
		} else {
			$spns = Test-DbaSpn -ComputerName $ScriptParams.ComputerName -EnableException
		}
		
		if ($spns.Count -gt 0) {
			foreach ($spn in $spns) {
				if ($spn.IsSet -ne $True) {
					if ($ScriptParams.Remediate -eq $True) {
						Set-DbaSpn -SPN $spn.RequiredSPN -ServiceAccount $spn.InstanceServiceAccount -WhatIf
					} else {
						$stat = "FAIL"
						$msg = "Missing SPN for $($spn.RequiredSPN)"
					}
				} else {
					$tempdata.Add($spn.RequiredSPN)
				}
			}
		} else {
			$stat = "FAIL"
			$msg  = "No SPNs have been registered"
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
