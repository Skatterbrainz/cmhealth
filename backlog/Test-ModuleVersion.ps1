function Test-CmHealthModuleVersion {
	try {
		$mv = Get-Module 'cmhealth' -ListAvailable | Select-Object -First 1 -ExpandProperty Version
		if ($null -ne $mv) {
			$mv = $mv -join '.'
			$fv = Find-Module 'cmhealth' | Select-Object -ExpandProperty Version
			if ([version]$fv -gt [version]$mv) {
				Write-Warning "$mv is installed. $fv is available"
			} else {
				Write-Host "cmhealth version $mv is the latest available" -ForegroundColor Green
			}
		} else {
			Write-Warning "cmhealth version could not be determined"
		}
	}
	catch {
		Write-Error $_.Exception.Message
	}
}