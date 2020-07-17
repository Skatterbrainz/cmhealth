function Test-CmHealth {
	[CmdletBinding()]
	param (
		[parameter()][ValidateNotNullOrEmpty()][string] $SiteServer = "localhost",
		[parameter()][ValidateNotNullOrEmpty()][string] $SqlInstance = "localhost",
		[parameter()][ValidateNotNullOrEmpty()][string] $Database = "CM_P01",
		[parameter()][ValidateLength(3,3)][string] $SiteCode = "",
		[parameter()][ValidateSet('All','Host','AD','SQL','CM')][string] $TestingScope = 'All',
		[parameter()][bool] $Remediate = $False
	)
	$startTime = (Get-Date)
	$params = [ordered]@{
		ComputerName = $SiteServer
		SqlInstance = $SqlInstance
		SiteCode = $SiteCode
		Database = $Database
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
			# Site System Configuration
			Test-ServiceAccounts -ScriptParams $params
			Test-IISLogFiles -ScriptParams $params
			Test-WsusIisAppPoolSettings -ScriptParams $params
			Test-WsusWebConfig -ScriptParams $params
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
		{ $_ -in ('All','CM') } {
			# Configuration Manager Site
			Test-CmMpResponse -ScriptParams $params
			Test-CmBoundaries -ScriptParams $params
			Test-CmCollectionRefresh -ScriptParams $params
			Test-CmCompStatus -ScriptParams $params
			# 
			# more tests needed!
			# 
			Test-CmClientCoverage -ScriptParams $params
		}
	}
	$runTime = New-TimeSpan -Start $startTime -End (Get-Date)
	Write-Host "testing completed: $($runTime.Hours) hrs $($runTime.Minutes) min $($runTime.Seconds) sec"
}
