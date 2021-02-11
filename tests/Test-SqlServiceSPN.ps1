function Test-SqlServiceSPN {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Test-SqlServiceSPN",
		[parameter()][string] $TestGroup = "configuration",
		[parameter()][string] $Description = "Verify SQL instance Service Principal Name registration",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		$startTime = (Get-Date)
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat   = "PASS"
		$except = "FAIL"
		$msg    = "No issues found"
		if ($null -ne $ScriptParams.Credential) {
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
						$stat = $except
						$msg  = "Missing SPN for $($spn.RequiredSPN)"
					}
				} else {
					$tempdata.Add($spn.RequiredSPN)
				}
			}
		} else {
			$stat = $except
			$msg  = "No SPNs have been registered"
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
