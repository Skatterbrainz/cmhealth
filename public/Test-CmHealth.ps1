<#
.SYNOPSIS
	Validate MECM/ConfigMgr site systems and configuration.
.DESCRIPTION
	Validate MECM/ConfigMgr site systems and configuration.
.PARAMETER SiteServer
	NetBIOS or FQDN of site server (primary, CAS, secondary). Default is localhost
.PARAMETER SqlInstance
	NetBIOS or FQDN of site database SQL instance. Default is localhost
.PARAMETER Database
	Name of site database. Default is "CM_P01"
.PARAMETER SiteCode
	ConfigMgr site code. Default is "P01"
.PARAMETER TestingScope
	Scope of tests to execute: All (default), Host, AD, SQL, CM, WSUS, Select
	The Select option displays a gridview to select the individual tests to perform
.PARAMETER Remediate
	Attempt remediation when possible
.PARAMETER Source
	Alternate source path for WinSXS referencing. Used only for Test-HostServerFeatures
	Default is C:\Windows\WinSxS
.PARAMETER DaysBack
	Number of days to go back for checking status messages, errors, warnings, etc. Default is 7
.PARAMETER Initialize
	Creates or resets a default configuration file on the current user's Desktop named "cmhealth.json"
.PARAMETER Credential
	PS Credential object for authenticating under alternate context
.EXAMPLE
	Test-CmHealth -Initialize
	Generates a new cmhealth.json configuration file on the user desktop. If the file exists, it will be replaced.
.EXAMPLE
	Test-CmHealth
	Runs all tests on the local machine using the current user credentials
.EXAMPLE
	Test-CmHealth -SiteServer "CM01" -SqlInstance "CM01" -Database "CM_P01" -SiteCode "P01" -TestingScope "ALL"
	Runs all tests
.EXAMPLE
	Test-CmHealth -SiteServer "CM01" -SqlInstance "CM01" -Database "CM_P01" -SiteCode "P01" -TestingScope "Host"
	Runs only the site server host tests
.EXAMPLE
	Test-CmHealth -SiteServer "CM01" -SqlInstance "CM01" -Database "CM_P01" -SiteCode "P01" -TestingScope "Host" -Remediate -Credential $cred
	Runs only the site server host tests and attempts to remediate identified deficiences using alternate user credentials
.EXAMPLE
	Test-CmHealth -SiteServer "CM01" -SqlInstance "CM01" -Database "CM_P01" -SiteCode "P01" -TestingScope "Host" -Remediate -Source "\\server3\sources\ws2019\WinSxS"
	Runs only the site server host tests and attempts to remediate identified deficiences with WinSXS source path provided
.EXAMPLE
	$failed = Test-CmHealth | Where-Object {$_.Status -eq "Fail"}
	Runs all tests and only returns those which failed 
.LINK
	https://github.com/Skatterbrainz/cmhealth/blob/master/docs/Test-CmHealth.md
.NOTES
	Thank you!
#>

function Test-CmHealth {
	[CmdletBinding()]
	param (
		[parameter()][ValidateNotNullOrEmpty()][string] $SiteServer = "localhost",
		[parameter()][ValidateNotNullOrEmpty()][string] $SqlInstance = "localhost",
		[parameter()][ValidateNotNullOrEmpty()][string] $Database = "CM_P01",
		[parameter()][ValidateLength(3,3)][string] $SiteCode = "",
		[parameter()][ValidateSet('All','Host','AD','SQL','CM','WSUS','Select')][string] $TestingScope = 'All',
		[parameter()][bool] $Remediate = $False,
		[parameter()][string] $Source = "c:\windows\winsxs",
		[parameter()][switch] $Initialize,
		[parameter()][pscredential] $Credential
	)
	if ($Initialize) {
		Write-Host "generating default cmhealth settings file..." -ForegroundColor Cyan
		$mpath = Split-Path $(Get-Module cmhealth).Path
		$rpath = "$($mpath)\reserve"
		$configFile = "$($rpath)\cmhealth.json"
		$targetPath = "$($env:USERPROFILE)\Desktop"
		Copy-Item -Path $configFile -Destination $targetPath -Force 
		Write-Host "cmhealth settings file saved as: $($targetPath)\cmhealth.json" -ForegroundColor Cyan
	} else {
		$startTime = (Get-Date)
		$Script:CmHealthConfig = Import-CmHealthSettings
		$params = [ordered]@{
			ComputerName = $SiteServer
			SqlInstance  = $SqlInstance
			SiteCode     = $SiteCode
			Database     = $Database
			Source       = $Source
			Remediate    = $Remediate
			Credential   = $Credential
			Verbose      = $VerbosePreference
		}
		$mpath = $(Split-Path (Get-Module cmhealth).Path)
		$tpath = "$($mpath)\tests"
		$tests = Get-ChildItem -Path $tpath -Filter "*.ps1"
		Write-Verbose "$($tests.Count) tests found in library"
		switch ($TestingScope) {
			'All' {
				$testset = @($tests.BaseName)
			}
			'Select' {
				$testset = @($tests.BaseName | Out-GridView -Title "Select Test to Execute" -OutputMode Multiple)
			}
			Default {
				$testset = @($tests.BaseName | Where-Object {$_ -match "Test-$($TestingScope)"})
			}
		}
		Write-Verbose "$($testset.Count) tests were selected"
		foreach ($test in $testset) {
			$testname = $test += ' -ScriptParams $params'
			Invoke-Expression -Command $testname
		}
		$runTime = New-TimeSpan -Start $startTime -End (Get-Date)
		Write-Host "completed $($testset.Count) tests in: $($runTime.Hours) hrs $($runTime.Minutes) min $($runTime.Seconds) sec"
	}
}
