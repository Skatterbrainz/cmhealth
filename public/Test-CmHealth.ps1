function Test-CmHealth {
	[CmdletBinding()]
	param (
		[parameter()][ValidateNotNullOrEmpty()][string] $SiteServer = "localhost",
		[parameter()][ValidateNotNullOrEmpty()][string] $SqlInstance = "localhost",
		[parameter()][ValidateNotNullOrEmpty()][string] $Database = "CM_P01",
		[parameter()][bool] $Remediate = $False
	)
	
	Test-AdSchemaExtension -ComputerName $SiteServer
	Test-AdSysMgtContainer -ComputerName $SiteServer
	Test-DiskSpace -ComputerName $SiteServer
	Test-DriveBlockSize -ComputerName $SiteServer
	Test-IESCDisabled -ComputerName $SiteServer
	Test-InstalledComponents -ComputerName $SiteServer
	Test-NoSmsOnDriveFile -ComputerName $SiteServer
	Test-ServiceAccounts -ComputerName $SiteServer
	Test-IISLogFiles -ComputerName $SiteServer
	Test-WsusIisAppPoolSettings -ComputerName $SiteServer
	Test-WsusWebConfig -ComputerName $SiteServer

	Test-SqlServerMemory -SqlInstance $SqlInstance
	Test-SqlDbDedicated -SqlInstance $SqlInstance
	Test-SqlServicesSPN -SqlInstance $SqlInstance
	Test-DbRecoveryModel -SqlInstance $SqlInstance -Database $Database
	Test-SqlDbFileGrowth -SqlInstance $SqlInstance -Database $Database
	Test-SqlIndexFragmentation -SqlInstance $SqlInstance
	Test-SqlAgentJobStatus -SqlInstance $SqlInstance
	Test-SqlRoleMembers -SqlInstance $SqlInstance
	Test-CmDbSize -SqlInstance $SqlInstance -Database $Database
	Test-SqlUpdates -SqlInstance $SqlInstance
	
	Test-CmBoundaries
	#Test-CollectionRefresh
	#
	Test-CmClientCoverage -SqlInstance $SqlInstance -Database $Database
}
