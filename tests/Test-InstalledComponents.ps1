function Test-InstalledComponents {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Validate Prerequisites",
		[parameter()][string] $TestGroup = "configuration",
		[parameter()][string] $Description = "Validate CM prerequisites and support components",
		[parameter()][bool] $Remediate = $False,
		[parameter()][string] $ComputerName = "localhost",
		[parameter()][string] $Database = ""
	)
	try {
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat = "PASS"
		$msg  = "All required components are installed"
		$mpath = Split-Path (Get-Module "cmhealth" | Select-Object -ExpandProperty Path)
		if ([string]::IsNullOrEmpty($mpath)) {
			$AppListFile = "$($mpath)\tests\applist.csv"
		}
		if (!(Test-Path $AppListFile)) {
			Write-Warning "file not found: $AppListFile"
			break
		}
		$applist = Import-Csv -Path $AppListFile
	
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
		$p = $null
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
