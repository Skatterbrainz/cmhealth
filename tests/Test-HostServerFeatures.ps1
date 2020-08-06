function Test-HostServerFeatures {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Test-HostServerFeatures",
		[parameter()][string] $TestGroup = "configuration",
		[parameter()][string] $Description = "Validate Windows Server roles and features for CM site systems",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat = "PASS"
		$msg = "No issues found"
		Import-Module ServerManager
		if ($ScriptParams.ComputerName -ne $env:COMPUTERNAME) {
			if ($ScriptParams.Credential) {
				$features = Get-WindowsFeature -ComputerName $ScriptParams.ComputerName -Credential $ScriptParams.Credential -ErrorAction Stop 
			} else {
				$features = Get-WindowsFeature -ComputerName $ScriptParams.ComputerName -ErrorAction Stop 
			}
		} else {
			$features = Get-WindowsFeature -ErrorAction Stop
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
					Write-Verbose "$($feature.Name) is not installed!"
					if ($ScriptParams.Remediate -eq $True) {
						try {
							Write-Host "installing: $($Feature.Name)" -ForegroundColor Cyan
							if ($ScriptParams.ComputerName -ne $env:COMPUTERNAME) {
								if ($ScriptParams.Credential) {
									Install-WindowsFeature -Name "$($Feature.Name)" -ComputerName $ScriptParams.ComputerName -Credential $ScriptParams.Credential -Source $ScriptParams.Source -LogPath $LogFile -WarningAction SilentlyContinue -ErrorAction Stop
								} else {
									Install-WindowsFeature -Name "$($Feature.Name)" -ComputerName $ScriptParams.ComputerName -Source $ScriptParams.Source -LogPath $LogFile -WarningAction SilentlyContinue -ErrorAction Stop
								}
							} else {
								Install-WindowsFeature -Name "$($Feature.Name)" -Source $ScriptParams.Source -LogPath $LogFile -WarningAction SilentlyContinue -ErrorAction Stop
							}
							$tempdata.Add([pscustomobject]@{
								Feature = $feature.Name
								Status  = "Remediated"
								Message = "Success"
							})
						}
						catch {
							$tempdata.Add([pscustomobject]@{
								Feature = $feature.Name
								Status  = "ERROR"
								Message = $_.Exception.Message -join ';'
							})
						}
					} else {
						$exceptions++
						$tempdata.Add([pscustomobject]@{
							Feature = $feature.Name 
							Statue  = "FAIL"
							Message = "Not installed"
						})
						$missing.Add($feature.Name)
					}
				}
				else {
					$tempdata.Add([pscustomobject]@{
						Feature = $feature.Name
						Status  = "PASS"
						Message = "Already installed"
					})
				}
			}
		}
		if ($exceptions -gt 0) {
			$stat = "FAIL"
			$msg  = "$exceptions features are missing: $($missing -join ',')"
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