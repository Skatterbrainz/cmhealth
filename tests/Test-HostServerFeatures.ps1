function Test-HostServerFeatures {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Installed Windows Features",
		[parameter()][string] $TestGroup = "configuration",
		[parameter()][string] $TestCategory = "HOST",
		[parameter()][string] $Description = "Validate Windows Server roles and features for CM site systems",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		$startTime = (Get-Date)
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat   = "PASS"
		$except = "FAIL"
		$msg    = "No issues found"
		Import-Module ServerManager
		if ($ScriptParams.ComputerName -ne $env:COMPUTERNAME) {
			if ($ScriptParams.Credential) {
				$features = Get-WindowsFeature -ComputerName $ScriptParams.ComputerName -Credential $ScriptParams.Credential -ErrorAction Stop | Sort-Object Name
			} else {
				$features = Get-WindowsFeature -ComputerName $ScriptParams.ComputerName -ErrorAction Stop | Sort-Object Name
			}
		} else {
			$features = Get-WindowsFeature -ErrorAction Stop | Sort-Object Name
		}
		$LogFile = Join-Path $env:TEMP "serverfeatures.log"
		if ($ScriptParams.Remediate -eq $True -and ([string]::IsNullOrEmpty($ScriptParams.Source))) {
			throw "Source parameter is required for -Remediate but was not specified"
		}

		$flist = @($CmHealthConfig.windowsfeatures.Feature)
		if ($flist.Count -lt 1) { throw "failed to read features list from cmhealth settings file" }
		$exceptions = 0
		[System.Collections.Generic.List[PSObject]]$missing = @()
		foreach ($feature in $features) {
			if ($feature.Name -in $flist) {
				if ($feature.Installed -ne $True) {
					Write-Log -Message "feature not installed: $($feature.Name)"
					if ($ScriptParams.Remediate -eq $True) {
						try {
							Write-Log -Message "installing: $($Feature.Name)"
							if ($ScriptParams.ComputerName -ne $env:COMPUTERNAME) {
								if ($ScriptParams.Credential) {
									Install-WindowsFeature -Name "$($Feature.Name)" -ComputerName $ScriptParams.ComputerName -Credential $ScriptParams.Credential -Source $ScriptParams.Source -LogPath $LogFile -WarningAction SilentlyContinue -ErrorAction Stop
								} else {
									Install-WindowsFeature -Name "$($Feature.Name)" -ComputerName $ScriptParams.ComputerName -Source $ScriptParams.Source -LogPath $LogFile -WarningAction SilentlyContinue -ErrorAction Stop
								}
							} else {
								Install-WindowsFeature -Name "$($Feature.Name)" -Source $ScriptParams.Source -LogPath $LogFile -WarningAction SilentlyContinue -ErrorAction Stop
							}
							$tempdata.Add(
								[pscustomobject]@{
									Feature = $feature.Name
									Status  = "Remediated"
									Message = "Success"
								}
							)
						}
						catch {
							$tempdata.Add(
								[pscustomobject]@{
									Feature = $feature.Name
									Status  = "ERROR"
									Message = $_.Exception.Message -join ';'
								}
							)
						}
					} else {
						$exceptions++
						$tempdata.Add(
							[pscustomobject]@{
								Feature = $feature.Name 
								Status  = $except
								Message = "Not installed"
							}
						)
						$missing.Add($feature.Name)
					}
				}
				else {
					Write-Log -Message "feature is installed: $($feature.Name)"
					$tempdata.Add(
						[pscustomobject]@{
							Feature = $feature.Name
							Status  = "PASS"
							Message = "Already installed"
						}
					)
				}
			}
		}
		if ($exceptions -gt 0) {
			$stat = $except
			$msg  = "$exceptions features are missing: $($missing -join ',')"
		}
	}
	catch {
		$stat = 'ERROR'
		$msg = $_.Exception.Message -join ';'
	}
	finally {
		$([pscustomobject]@{
			TestName    = $TestName
			TestGroup   = $TestGroup
			Category    = $TestCategory
			TestData    = $tempdata
			Description = $Description
			Status      = $stat
			Message     = $msg
			RunTime     = $(Get-RunTime -BaseTime $startTime)
			Credential  = $(if($ScriptParams.Credential){$($ScriptParams.Credential).UserName} else { $env:USERNAME })
		})
	}
}