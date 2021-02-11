function Test-Example {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Test-Example",
		[parameter()][string] $TestGroup = "configuration",
		[parameter()][string] $Description = "Description of this test",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		$startTime = (Get-Date)
		#[int]$Setting = Get-CmHealthDefaultValue -KeySet "keygroup:keyname" -DataSet $CmHealthConfig
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat = "PASS" # do not change this
		$except = "WARNING" # or "FAIL"
		$msg  = "No issues found" # do not change this either
		<#
		=======================================================
		|	COMMENT: DELETE THIS BLOCK WHEN FINISHED:
		|
		|	perform test and return result as an object...
		|		$stat = "FAIL" or "WARNING" (no need to set "PASS" since it's the default)
		|		$msg = (details of failure or warning)
		|		add supporting data to $tempdata array if it helps output
		|		loop output into $tempdata.Add() array to return as TestData param in output
		=======================================================
		#>

		<#
		=======================================================
		COMMENT: EXAMPLE FOR SQL QUERY RELATED TESTS... DELETE THIS BLOCK IF NOT USED
		=======================================================

		$query = ""
		if ($ScriptParams.Credential) {
			$res = @(Invoke-DbaQuery -SqlInstance $ScriptParams.SqlInstance -Database $ScriptParams.Database -Query $query -SqlCredential $ScriptParams.Credential)
		} else {
			$res = @(Invoke-DbaQuery -SqlInstance $ScriptParams.SqlInstance -Database $ScriptParams.Database -Query $query)
		}

		if ($res.Count -gt 0) {
			$stat = $except
			$msg  = "$($res.Count) items found"
			#$res | Foreach-Object {$tempdata.Add($_.Name)}
		}
		#>

		<#
		=======================================================
		COMMENT: EXAMPLE FOR WMI/CIM QUERY RELATED TESTS... DELETE THIS BLOCK IF NOT USED
		=======================================================

		if ($ScriptParams.ComputerName -ne $env:COMPUTERNAME) {
			if ($ScriptParams.Credential) {
				$cs = New-CimSession -Credential $ScriptParams.Credential -Authentication Negotiate -ComputerName $ScriptParams.ComputerName
				$services = @(Get-CimInstance -CimSession $cs -ClassName Win32_Service | Where-Object {$_.StartMode -match 'auto' -and $_.State -ne 'Running'})
			} else {
				$services = @(Get-CimInstance -ComputerName $ScriptParams.ComputerName -ClassName Win32_Service | Where-Object {$_.StartMode -match 'auto' -and $_.State -ne 'Running'})
			}
		} else {
			$services = @(Get-CimInstance -ClassName Win32_Service | Where-Object {$_.StartMode -match 'auto' -and $_.State -ne 'Running'})
		}
		if ($services.Count -gt 0) {
			$stat = $except
			$services | Foreach-Object {$tempdata.Add($_.Name)}
			$msg = "$($services.Count) stopped services were found"
			$services | Foreach-Object {$tempdata.Add($_.Name)}
		}

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
