function Test-InstalledComponents {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Test-InstalledComponents",
		[parameter()][string] $TestGroup = "configuration",
		[parameter()][string] $Description = "Validate CM prerequisites and support components",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat = "PASS"
		$msg  = "All required components are installed"
		$mpath = Split-Path (Get-Module "cmhealth" | Select-Object -ExpandProperty Path)
		Write-Verbose "module path = $mpath"
		if (![string]::IsNullOrEmpty($mpath)) {
			$AppListFile = "$($mpath)\tests\applist.csv"
			Write-Verbose "applist file = $AppListFile"
		}
		if (!(Test-Path $AppListFile)) {
			throw "file not found: $AppListFile"
		} else {
			Write-Verbose "path verified to $AppListFile"
		}
		$applist = Import-Csv -Path "$AppListFile"
	
		$reg64 = Get-ChildItem -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall
		$reg32 = Get-ChildItem -Path HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall
	
		$reg64 | ForEach-Object {
			if ($_.Property -contains 'DisplayName') {
				$pn = $_.GetValue('DisplayName')
				$pv = $_.GetValue('DisplayVersion')
				if ($pn -in $applist.ProductName) {
					$app = $applist | Where-Object {$_.ProductName -eq $pn}
					if ($app.Version -ne $pv) {
						$compliant = 'FAIL'
					}
					$tempdata.Add([pscustomobject]@{
						ProductName = $pn
						Version   = $pv
						Required  = $app.Version
						Compliant = $compliant
						Platform  = 64
					})
				}
			}
		}
		$app = $null
		$pn = $null
		$pv = $null
		$reg32 | ForEach-Object {
			if ($_.Property -contains 'DisplayName') {
				$pn = $_.GetValue('DisplayName')
				$pv = $_.GetValue('DisplayVersion')
				if ($pn -in $applist.ProductName) {
					$app = $applist | Where-Object {$_.ProductName -eq $pn}
					if ($app.Version -ne $pv) {
						$compliant = $False
					}
					$tempdata.Add([pscustomobject]@{
						ProductName = $pn
						Version   = $pv
						Required  = $app.Version
						Compliant = $compliant
						Platform  = 32
					})
				}
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
