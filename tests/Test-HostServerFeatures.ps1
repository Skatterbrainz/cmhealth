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
		$flist = @($CmHealthConfig.windowsfeatures.Feature)
		if ($flist.Count -lt 1) { throw "failed to read features list from cmhealth settings file" }
		$exceptions = 0
		[System.Collections.Generic.List[PSObject]]$missing = @()
		foreach ($feature in $features) {
			if ($feature.Name -in $flist) {
				if ($feature.Installed -ne $True) {
					Write-Log -Message "feature not installed: $($feature.Name)"
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
		} # foreach
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
		Set-CmhOutputData
	}
}