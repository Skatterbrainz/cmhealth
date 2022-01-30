function Test-HostInstalledComponents {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Installed Software Components",
		[parameter()][string] $TestGroup = "configuration",
		[parameter()][string] $TestCategory = "HOST",
		[parameter()][string] $Description = "Validate CM prerequisites and support components",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		$startTime = (Get-Date)
		$applist = Get-CmHealthDefaultValue -KeySet "applications" -DataSet $CmHealthConfig
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat   = "PASS"
		$except = "FAIL"
		$msg    = "All required components are installed"
		$reg64 = Get-ChildItem -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall 
		$reg32 = Get-ChildItem -Path HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall
		$reg64 | ForEach-Object {
			if ($_.Property -contains 'DisplayName') {
				$pn = $_.GetValue('DisplayName')
				$pv = $_.GetValue('DisplayVersion')
				if ($pn -in $applist.ProductName) {
					$app = $applist | Where-Object {$_.ProductName -eq $pn}
					if ($app.Version -ge $pv) {
						$compliant = $except
					} else {
						$compliant = $True
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
					if ($app.Version -ge $pv) {
						$compliant = $False
					} else {
						$compliant = $True
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
		Set-CmhOutputData
	}
}
