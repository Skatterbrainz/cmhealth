function Test-SqlDatabaseNameDefault {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Check if SQL DB name uses default format",
		[parameter()][string] $TestGroup = "configuration",
		[parameter()][string] $Description = "Check if site database name is using the CM_XXX format",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		$startTime = (Get-Date)
		#[int]$Setting = Get-CmHealthDefaultValue -KeySet "keygroup:keyname" -DataSet $CmHealthConfig
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat   = "PASS" # do not change this
		$except = "WARNING" # or "FAIL"
		$msg    = "No issues found" # do not change this either
		$regkey = "HKLM:\SOFTWARE\Microsoft\SMS\SQL Server"
		$vname  = "Database Name"

		$reghost = $ScriptParams.ComputerName
		$dbname  = ""
		if ($reghost -eq $env:COMPUTERNAME) {
			Write-Log -Message "reading local registry: $regkey"
			$dbname = Get-RegistryValueData -RegistryHive LocalMachine -RegistryKeyPath $regkey -ValueName $vname
		} else {
			Write-Log -Message "reading remote registry: $regkey"
			$dbname = Get-RegistryValueData -ComputerName $reghost -RegistryHive LocalMachine -RegistryKeyPath $regkey -ValueName $vname
		}

		if (![string]::IsNullOrEmpty($dbname)) {
			if (-not($dbname.StartsWith('CM_'))) {
				$stat = $except
				$msg = "$dbname is not using the default naming format"
				Write-Log -Message $msg -Category $except
			} else {
				$msg = "$dbname is using the default naming format"
				Write-Log -Message $msg
			}
		} else {
			Write-Log -Message "Unable to read registry data" -Category Error
		}

		$tempdata.Add(
			[pscustomobject]@{
				Status = $stat
				ComputerName = $reghost
				DatabaseName = $dbname
				Message = $msg
			}
		)
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
			RunTime     = $(Get-RunTime -BaseTime $startTime)
			Credential  = $(if($ScriptParams.Credential){$($ScriptParams.Credential).UserName} else { $env:USERNAME })
		})
	}
}
