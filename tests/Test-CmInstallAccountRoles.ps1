function Test-CmInstallAccountRoles {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Test-CmInstallAccountRoles",
		[parameter()][string] $TestGroup = "configuration",
		[parameter()][string] $Description = "Check if site install account has more permissions/roles than it needs",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		$startTime = (Get-Date)
		#[int]$Setting = Get-CmHealthDefaultValue -KeySet "keygroup:keyname" -DataSet $CmHealthConfig
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat   = "PASS" # do not change this
		$except = "WARNING" # or "FAIL"
		$msg    = "No issues found" # do not change this either
		[array]$localAdmins = Get-LocalGroupMember -Group "Administrators" -ErrorAction Stop
		$query = "SELECT TOP (1) LogonName FROM dbo.vRBAC_Permissions WHERE CategoryID = 'SMS00ALL'"
		$res = Get-CmSqlQueryResult -Query $query -Params $ScriptParams
		if ($null -ne $res) {
			$username = $res.LogonName
			if ($localAdmins.Name -contains $username) {
				Write-Verbose "install account is a direct member of local administrators group"
			}
			try {$user = Get-ADUser -Identity $res.LogonName -Filter * -ErrorAction SilentlyContinue} catch {}
			if ($null -ne $user) {
				# got the AD account
			} else {
				Write-Warning "site installation account not found in the directory!"
			}
		} else {
			Write-Warning "unable to query site installation account from database"
		}
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
