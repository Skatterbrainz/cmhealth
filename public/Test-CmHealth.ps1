<#
.SYNOPSIS
	Validate MECM/ConfigMgr site systems and configuration
.DESCRIPTION
	Validate MECM/ConfigMgr site systems and configuration
.PARAMETER SiteServer
	NetBIOS or FQDN of site server (primary, CAS, secondary)
.PARAMETER SqlInstance
	NetBIOS or FQDN of site database SQL instance
.PARAMETER Database
	Name of site database
.PARAMETER SiteCode
	ConfigMgr site code
.PARAMETER TestingScope
	Scope of tests to execute
.PARAMETER Remediate
	Attempt remediation when possible
.EXAMPLE
	Test-CmHealth -SiteServer "CM01" -SqlInstance "CM01" -Database "CM_P01" -SiteCode "P01" -TestingScope "ALL"
	Runs all tests
.EXAMPLE
	Test-CmHealth -SiteServer "CM01" -SqlInstance "CM01" -Database "CM_P01" -SiteCode "P01" -TestingScope "Host"
	Runs only the site server host tests
.EXAMPLE
	Test-CmHealth -SiteServer "CM01" -SqlInstance "CM01" -Database "CM_P01" -SiteCode "P01" -TestingScope "Host" -Remediate
	Runs only the site server host tests and attempts to remediate identified deficiences

#>
function Test-CmHealth {
	[CmdletBinding()]
	param (
		[parameter()][ValidateNotNullOrEmpty()][string] $SiteServer = "localhost",
		[parameter()][ValidateNotNullOrEmpty()][string] $SqlInstance = "localhost",
		[parameter()][ValidateNotNullOrEmpty()][string] $Database = "CM_P01",
		[parameter()][ValidateLength(3,3)][string] $SiteCode = "",
		[parameter()][ValidateSet('All','Host','AD','SQL','CM','IIS','Select')][string] $TestingScope = 'All',
		[parameter()][bool] $Remediate = $False,
		[parameter()][string] $Source = "c:\windows\winsxs"
	)
	$startTime = (Get-Date)
	$params = [ordered]@{
		ComputerName = $SiteServer
		SqlInstance  = $SqlInstance
		SiteCode     = $SiteCode
		Database     = $Database
		Source       = $Source
		Remediate    = $Remediate
		Verbose      = $VerbosePreference
	}
	switch ($TestingScope) {
		{ $_ -in ('All','Host') } {
			# Site System Host
			Test-HostOperatingSystem -ScriptParams $params
			Test-HostMemory -ScriptParams $params
			Test-ServerFeatures -ScriptParams $params
			Test-DiskSpace -ScriptParams $params
			Test-DriveBlockSize -ScriptParams $params
			Test-IESCDisabled -ScriptParams $params
			Test-InstalledComponents -ScriptParams $params
			Test-NoSmsOnDriveFile -ScriptParams $params	
			Test-ServiceAccounts -ScriptParams $params
			Test-HostServices -ScriptParams $params
		}
		{ $_ -in ('All','SQL') } {
			Test-SqlServerMemory -ScriptParams $params
			Test-SqlDbCollation -ScriptParams $params
			Test-SqlDbDedicated -ScriptParams $params
			Test-SqlServicesSPN -ScriptParams $params
			Test-SqlDbBackupHistory -ScriptParams $params
			Test-DbRecoveryModel -ScriptParams $params
			Test-SqlDbFileGrowth -ScriptParams $params
			Test-SqlIndexFragmentation -ScriptParams $params
			Test-SqlAgentJobStatus -ScriptParams $params
			Test-SqlRoleMembers -ScriptParams $params
			Test-CmDbSize -ScriptParams $params
			Test-SqlUpdates -ScriptParams $params
		}
		{ $_ -in ('All','AD') } {
			# Active Directory
			Test-AdSchemaExtension -ScriptParams $params
			Test-AdSysMgtContainer -ScriptParams $params
		}
		{ $_ -in ('All','IIS') } {
			Test-IISLogFiles -ScriptParams $params
			Test-WsusIisAppPoolSettings -ScriptParams $params
			Test-WsusWebConfig -ScriptParams $params
		}
		{ $_ -in ('All','CM') } {
			# Configuration Manager Site
			Test-CmMpResponse -ScriptParams $params
			Test-CmBoundaries -ScriptParams $params
			Test-CmCollectionRefresh -ScriptParams $params
			Test-CmCompStatus -ScriptParams $params
			Test-CmLastBackup -ScriptParams $params
			Test-CmWsusLastSync -ScriptParams $params 
			# 
			# more tests needed!
			# 
			Test-CmClientCoverage -ScriptParams $params
		}
		'Select' {
			$mpath = Split-Path $(Get-Module cmhealth).Path
			$tpath = "$($mpath)\tests"
			$tests = Get-ChildItem -Path $tpath -Filter "*.ps1" | Select Name,FullName | Sort-Object Name
			$test = $tests | Out-GridView -Title "Select Test to Execute" -OutputMode Single
			if ($null -ne $test) {
				$testname = $($test.Name -replace '.ps1','')
				$testname += ' -ScriptParams $params'
				Invoke-Expression -Command $testname
			}
		}
	}
	$runTime = New-TimeSpan -Start $startTime -End (Get-Date)
	Write-Host "testing completed: $($runTime.Hours) hrs $($runTime.Minutes) min $($runTime.Seconds) sec"
}
