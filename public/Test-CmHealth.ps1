function Test-CmHealth {
	[CmdletBinding()]
	param (
		[parameter()][ValidateNotNullOrEmpty()][string] $SiteServer = "localhost",
		[parameter()][ValidateNotNullOrEmpty()][string] $SqlInstance = "localhost",
		[parameter()][ValidateNotNullOrEmpty()][string] $Database = "CM_P01",
		[parameter()][ValidateLength(3,3)][string] $SiteCode = "",
		[parameter()][bool] $Remediate = $False
	)
	# Site System Host
	Test-HostOperatingSystem -ComputerName $SiteServer
	Test-HostMemory -ComputerName $SiteServer
	Test-ServerFeatures -ComputerName $SiteServer 
	Test-DiskSpace -ComputerName $SiteServer
	Test-DriveBlockSize -ComputerName $SiteServer
	Test-IESCDisabled -ComputerName $SiteServer
	Test-InstalledComponents -ComputerName $SiteServer
	Test-NoSmsOnDriveFile -ComputerName $SiteServer

	# Site System Configuration
	Test-ServiceAccounts -ComputerName $SiteServer
	Test-IISLogFiles -ComputerName $SiteServer
	Test-WsusIisAppPoolSettings -ComputerName $SiteServer
	Test-WsusWebConfig -ComputerName $SiteServer

	# Active Directory
	Test-AdSchemaExtension -ComputerName $SiteServer
	Test-AdSysMgtContainer -ComputerName $SiteServer

	# SQL Server
	Test-SqlServerMemory -SqlInstance $SqlInstance
	Test-SqlDbCollation -SqlInstance $SqlInstance -Database $Database
	Test-SqlDbDedicated -SqlInstance $SqlInstance
	Test-SqlServicesSPN -SqlInstance $SqlInstance
	Test-SqlDbBackupHistory -SqlInstance $SqlInstance -Database $Database
	Test-DbRecoveryModel -SqlInstance $SqlInstance -Database $Database
	Test-SqlDbFileGrowth -SqlInstance $SqlInstance -Database $Database
	Test-SqlIndexFragmentation -SqlInstance $SqlInstance
	Test-SqlAgentJobStatus -SqlInstance $SqlInstance
	Test-SqlRoleMembers -SqlInstance $SqlInstance
	Test-CmDbSize -SqlInstance $SqlInstance -Database $Database
	Test-SqlUpdates -SqlInstance $SqlInstance
	
	# Configuration Manager Site
	Test-CmMpResponse -ComputerName $SiteServer
	Test-CmBoundaries -SqlInstance $SqlInstance -Database $Database
	Test-CmCollectionRefresh -SqlInstance $SqlInstance -Database $Database
	# 
	# more tests needed!
	# 
	Test-CmClientCoverage -SqlInstance $SqlInstance -Database $Database
}
