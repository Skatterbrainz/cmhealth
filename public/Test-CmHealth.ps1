function Test-CmHealth {
	[CmdletBinding()]
	param (
		[parameter()][ValidateNotNullOrEmpty()][string] $SiteServer = "localhost",
		[parameter()][ValidateNotNullOrEmpty()][string] $SqlInstance = "localhost",
		[parameter()][ValidateNotNullOrEmpty()][string] $Database = "CM_P01",
		[parameter()][ValidateLength(3,3)][string] $SiteCode = "",
		[parameter()][bool] $Remediate = $False
	)
	$params = [ordered]@{
		ComputerName = $SiteServer
		SqlInstance = $SqlInstance
		SiteCode = $SiteCode
		Database = $Database
	}
	# Site System Host
	Test-HostOperatingSystem -ScriptParams $ScriptParams
	Test-HostMemory -ScriptParams $ScriptParams
	Test-ServerFeatures -ScriptParams $ScriptParams
	Test-DiskSpace -ScriptParams $ScriptParams
	Test-DriveBlockSize -ScriptParams $ScriptParams
	Test-IESCDisabled -ScriptParams $ScriptParams
	Test-InstalledComponents -ScriptParams $ScriptParams
	Test-NoSmsOnDriveFile -ScriptParams $ScriptParams

	# Site System Configuration
	Test-ServiceAccounts -ScriptParams $ScriptParams
	Test-IISLogFiles -ScriptParams $ScriptParams
	Test-WsusIisAppPoolSettings -ScriptParams $ScriptParams
	Test-WsusWebConfig -ScriptParams $ScriptParams

	# Active Directory
	Test-AdSchemaExtension -ScriptParams $ScriptParams
	Test-AdSysMgtContainer -ScriptParams $ScriptParams

	# SQL Server
	Test-SqlServerMemory -ScriptParams $ScriptParams
	Test-SqlDbCollation -ScriptParams $ScriptParams
	Test-SqlDbDedicated -ScriptParams $ScriptParams
	Test-SqlServicesSPN -ScriptParams $ScriptParams
	Test-SqlDbBackupHistory -ScriptParams $ScriptParams
	Test-DbRecoveryModel -ScriptParams $ScriptParams
	Test-SqlDbFileGrowth -ScriptParams $ScriptParams
	Test-SqlIndexFragmentation -ScriptParams $ScriptParams
	Test-SqlAgentJobStatus -ScriptParams $ScriptParams
	Test-SqlRoleMembers -ScriptParams $ScriptParams
	Test-CmDbSize -ScriptParams $ScriptParams
	Test-SqlUpdates -ScriptParams $ScriptParams
	
	# Configuration Manager Site
	Test-CmMpResponse -ScriptParams $ScriptParams
	Test-CmBoundaries -ScriptParams $ScriptParams
	Test-CmCollectionRefresh -ScriptParams $ScriptParams
	# 
	# more tests needed!
	# 
	Test-CmClientCoverage -ScriptParams $ScriptParams
}
