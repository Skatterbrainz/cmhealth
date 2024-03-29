#requires -RunAsAdministrator
function Test-CmHealth {
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
	
		* All - runs all tests
		* Host - runs tests against the host machine (OS, memory, storage, etc.)
		* SQL - runs tests against, well, yes, the SQL Server instance
		* CM - run tests against, ok, really? do I have to spell this out?
		* WSUS - okay, enough of this already!
		* Select - any questions?
	
	.PARAMETER ConfigFile
		Path to cmhealth.json (create or import). If not found, it will attempt to create a new
		one in the specified path.  The default path is the user TEMP folder.
	
	.PARAMETER DaysBack
		Number of days to go back for checking status messages, errors, warnings, etc. Default is 7
	
	.PARAMETER Credential
		PS Credential object for authenticating under alternate context
	
	.PARAMETER LogFile
		Path and name of log file. Default is $env:TEMP\cmhealth_yyyy-mm-dd.log
	
	.PARAMETER NoVersionCheck
		Skip checking for newer module version (default is to attempt a version check)
	
	.PARAMETER AllServers
		Run tests on all site systems within the current ConfigMgr site database
	
	.EXAMPLE
		Test-CmHealth -SiteCode "P01" -Database "CM_P01"
		Runs all tests on the local machine 
	
	.EXAMPLE
		Test-CmHealth -SiteCode "P01" -Database "CM_P01" -AllServers
		Runs all tests on all site systems 
	
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
		Thank you! If you actually read this help stuff, drop me a DM on Twitter @skatterbrainzz
	#>
	[CmdletBinding()]
		[OutputType()]
		param (
			[parameter(Mandatory=$True)][ValidateLength(3,3)][string] $SiteCode,
			[parameter(Mandatory=$True)][ValidateNotNullOrEmpty()][string] $Database,
			[parameter(Mandatory=$False)][ValidateNotNullOrEmpty()][string] $SiteServer = "$((Get-WmiObject win32_computersystem).DNSHostName+"."+$(Get-WmiObject win32_computersystem).Domain)",
			[parameter(Mandatory=$False)][ValidateNotNullOrEmpty()][string] $SqlInstance = "$((Get-WmiObject win32_computersystem).DNSHostName+"."+$(Get-WmiObject win32_computersystem).Domain)",
			[parameter(Mandatory=$False)][ValidateSet('All','AD','CM','Host','SQL','WSUS','Select','Previous')][string] $TestingScope = 'All',
			[parameter(Mandatory=$False)][string]$ConfigFile = "$($env:TEMP)\cmhealth.json",
			[parameter(Mandatory=$False)][pscredential] $Credential,
			[parameter(Mandatory=$False)][string]$LogFile = "$($env:TEMP)\cmhealth_$(Get-Date -f 'yyyy-MM-dd').log",
			[parameter(Mandatory=$False)][switch]$NoVersionCheck,
			[parameter(Mandatory=$False)][switch]$AllServers
		)
		if (-not($NoVersionCheck)) { Test-CmHealthModuleVersion }
		if (-not(Test-Path $ConfigFile)) { New-CmHealthConfig -Path $ConfigFile }
		$startTime1 = (Get-Date)
		Write-Host "Thank you for using CMHealth! (and your ConfigMgr site thanks you too)" -ForegroundColor Cyan
		Write-Host "Thanks to the authors of PowerShell modules: DbaTools, Carbon, AdsiPS and psWindowsUpdate" -ForegroundColor Cyan
		#Write-Warning "If you haven't refreshed the cmhealth.json file since 0.2.24 or earlier, rename or delete the file and run this command again."
		Write-Host "log file = $LogFile"
		Write-Log -Message "------------------ begin processing --------------------"
		if (!(Test-Path "$ConfigFile")) {
			Write-Log -Message "Default configuration has not been defined." -Category Error -Show
			break
		}
		$Script:CmHealthConfig = Import-CmHealthSettings -Primary $ConfigFile
		if ($null -eq $CmHealthConfig) {
			Write-Log -Message "configuration data could not be imported" -Category Error -Show
			break
		}
		$GLOBAL:CmhParams = [ordered]@{
			ComputerName = $SiteServer
			SqlInstance  = $SqlInstance
			SiteCode     = $SiteCode
			Database     = $Database
			Credential   = $Credential
			LogFile      = $LogFile
			Verbose      = $VerbosePreference
		}
		#$GLOBAL:CmhParams = $params
		$mpath = $(Split-Path (Get-Module cmhealth).Path)
		$tpath = "$($mpath)\tests"
		$tests = Get-ChildItem -Path $tpath -Filter "*.ps1"
		Write-Log -Message "$($tests.Count) tests found in library"
		Write-Log -Message "testing scope = $TestingScope"
		if ($TestingScope -in ('All','AD')) {
			Write-Log -Message "AD tests may require RSAT to be installed" -Category Warning -Show
		}
		switch ($TestingScope) {
			'All' {
				$testset = @($tests.BaseName)
			}
			'Select' {
				$testfiles = @($tests.FullName | ForEach-Object { Get-TestParams -FilePath $_ })
				$testset = @($testfiles | Select-Object FileBase, TestName,TestCategory | Out-GridView -Title "Select Test to Execute" -OutputMode Multiple)
			}
			'Previous' {
				$testset = @(Get-CmHealthLastTestSet)
			}
			Default {
				$testset = @($tests.BaseName | Where-Object {$_ -match "Test-$($TestingScope)"})
			}
		}
		Write-Log -Message "$($testset.Count) tests were selected"
		if ($testset.Count -gt 0) {
			Write-Log -Message "saving test selection to history file"
			Set-CmHealthLastTestSet -TestNames $testset | Out-Null
		} else {
			Write-Log -Message "no tests were selected"
		}
		$testcount = $testset.Count
		$counter = 1
		if ($AllServers) {
			[array]$siteSystems = Get-CmSiteServersList -ComputerName $cmhParams.ComputerName -SiteCode $cmhParams.SiteCode
			if ($siteSystems.Count -gt 0) {
				foreach ($server in $siteSystems) {
					$cmhParams.ComputerName = $server.ServerName
					foreach ($test in $testset) {
						Write-Log -Message "$($server.ServerName): TEST $counter of $testcount`: $test" -Show
						$testname = $test += ' -ScriptParams $CmhParams'
						Invoke-Expression -Command $testname
						$counter++
					}
				}
			} else {
				Write-Log -Message "failed to get list of site systems" -Category Error -Show
			}
		} else {
			foreach ($test in $testset) {
				Write-Log -Message "TEST $counter of $testcount`: $test" -Show
				$testname = $test += ' -ScriptParams $CmhParams'
				Invoke-Expression -Command $testname
				$counter++
			}
		}
		$runTime = New-TimeSpan -Start $startTime1 -End (Get-Date)
		Write-Log -Message "completed $($testset.Count) tests in: $($runTime.Hours) hrs $($runTime.Minutes) min $($runTime.Seconds) sec" -Show
	}
	