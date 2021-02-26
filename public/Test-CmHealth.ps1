#requires -RunAsAdministrator
<#
.SYNOPSIS
	Validate MECM/ConfigMgr site systems and configuration.
.DESCRIPTION
	Validate MECM/ConfigMgr site systems operational health status, and recommended configuration.
.PARAMETER SiteCode
	ConfigMgr 3-character alphanumeric site code.
.PARAMETER Database
	Name of site SQL database.
.PARAMETER SiteServer
	NetBIOS or FQDN of site server (primary, CAS, secondary). Default is localhost
.PARAMETER SqlInstance
	NetBIOS or FQDN of site database SQL instance. Default is localhost
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
.PARAMETER Credential
	PS Credential object for authenticating under alternate context
.EXAMPLE
	Test-CmHealth -SiteCode "P01" -Database "CM_P01"
	Runs all tests on the local machine using the current user credentials
.EXAMPLE
	Test-CmHealth -SiteCode "P01" -Database "CM_P01" -SiteServer "CM01" -SqlInstance "CM01" -TestingScope "ALL"
	Runs all tests
.EXAMPLE
	Test-CmHealth -SiteCode "P01" -Database "CM_P01" -SiteServer "CM01" -SqlInstance "CM01" -TestingScope "Host"
	Runs only the site server host tests
.EXAMPLE
	Test-CmHealth -SiteCode "P01" -Database "CM_P01" -SiteServer "CM01" -SqlInstance "CM01" -TestingScope "Host" -Remediate -Credential $cred
	Runs only the site server host tests and attempts to remediate identified deficiences using alternate user credentials
.EXAMPLE
	Test-CmHealth -SiteCode "P01" -Database "CM_P01" -SiteServer "CM01" -SqlInstance "CM01" -TestingScope "Host" -Remediate -Source "\\server3\sources\ws2019\WinSxS"
	Runs only the site server host tests and attempts to remediate identified deficiences with WinSXS source path provided
.EXAMPLE
	$failed = Test-CmHealth -SiteCode "P01" -Database "CM_P01" | Where-Object Status -eq 'Fail'
	Runs all tests and only returns those which failed
.EXAMPLE
	Test-CmHealth -SiteCode "P01" -Database "CM_P01" | Select-Object TestName,Status,Message | Where-Object Status -eq 'Fail'
	Display summary of failed tests
.EXAMPLE
	$results = Test-CmHealth -SiteCode "P01" -Database "CM_P01" | Where-Object Status -eq 'Fail'; $results | Select TestData
	Display test output from failed tests
.EXAMPLE
	$results = Test-CmHealth -SiteCode "P01" -Database "CM_P01" -TestScope Previous
	Run the same set of tests as the previous session (each run saves list of test names)
.LINK
	https://github.com/Skatterbrainz/cmhealth/blob/master/docs/Test-CmHealth.md
.NOTES
	Thank you!
#>

function Test-CmHealth {
	[CmdletBinding()]
	param (
		[parameter(Mandatory=$True)][ValidateLength(3,3)][string] $SiteCode,
		[parameter(Mandatory=$True)][ValidateNotNullOrEmpty()][string] $Database,
		[parameter(Mandatory=$False)][ValidateNotNullOrEmpty()][string] $SiteServer = "localhost",
		[parameter(Mandatory=$False)][ValidateNotNullOrEmpty()][string] $SqlInstance = "localhost",
		[parameter(Mandatory=$False)][ValidateSet('All','AD','CM','Host','SQL','WSUS','Select','Previous')][string] $TestingScope = 'All',
		[parameter(Mandatory=$False)][boolean] $Remediate = $False,
		[parameter(Mandatory=$False)][string] $Source = "c:\windows\winsxs",
		[parameter(Mandatory=$False)][pscredential] $Credential
	)
	[string]$cfgfile = "$($env:USERPROFILE)\Desktop\cmhealth.json"
	if (-not(Test-Path $cfgfile)) {
		New-CmHealthConfig
	} else {
		$startTime1 = (Get-Date)
		if (!(Test-Path "$($env:USERPROFILE)\Desktop\cmhealth.json")) {
			Write-Warning "Default configuration has not been defined. Use 'Test-CmHealth -Initialize' first"
			break
		}
		$Script:CmHealthConfig = Import-CmHealthSettings
		if ($null -eq $CmHealthConfig) {
			Write-Warning "configuration data could not be imported"
			break
		}
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
			'Previous' {
				$testset = @(Get-CmHealthLastTestSet)
			}
			Default {
				$testset = @($tests.BaseName | Where-Object {$_ -match "Test-$($TestingScope)"})
			}
		}
		Write-Verbose "$($testset.Count) tests were selected"
		if ($testset.Count -gt 0) {
			Set-CmHealthLastTestSet -TestNames $testset | Out-Null
		}
		foreach ($test in $testset) {
			Write-Verbose "TEST: $test"
			$testname = $test += ' -ScriptParams $params'
			Invoke-Expression -Command $testname
		}
		$runTime = New-TimeSpan -Start $startTime1 -End (Get-Date)
		Write-Host "completed $($testset.Count) tests in: $($runTime.Hours) hrs $($runTime.Minutes) min $($runTime.Seconds) sec"
	}
}
