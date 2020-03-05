function Get-CmHealth {
	[CmdletBinding()]
	param (
		[parameter()][ValidateNotNullOrEmpty()][string] $SiteServer = $($env:COMPUTERSYSTEM),
		[parameter()][ValidateLength(3,3)][string] $SiteCode,
		[parameter()][string] $OutputFolder = "$($env:USERPROFILE)\Documents"
	)
	$filepath = "$OutputFolder\$SiteServer`_$(Get-Date -f 'yyyy-MM-dd').htm"
	try {
		<#
		computer system
		operating system
		memory
		process
		disks
		applications
		updates-hotfixes
		services
		processes
		local groups
		local users
		#>

		$cs = Get-CimInstance -ClassName Win32_ComputerSystem -ComputerName $SiteServer |
					Select-Object Name,Manufacturer,Model,SystemType,TotalPhysicalMemory | ForEach-Object {
						[pscustomobject]@{
							Name         = $_.Name
							Manufacturer = $_.Manufacturer
							Model        = $_.Model
							SystemType   = $_.SystemType
							TotalMemory  = "$([math]::Round($_.TotalPhysicalMemory / 1GB, 2)) GB"
						}
					}
		$os = Get-CimInstance -ClassName Win32_OperatingSystem -ComputerName $SiteServer |
					Select-Object Caption,Version,InstallDate,OSType,OSArchitecture,OperatingSystemSKU
		$disks = Get-CimInstance -ClassName Win32_LogicalDisk -ComputerName $SiteServer |	
					Select-Object DeviceID,Size,FreeSpace,FileSystem,VolumeName,DriveType,NumberOfBlocks
		$proc = Get-CimInstance -ClassName Win32_Processor -ComputerName $SiteServer |
					Select-Object Name,Description,Manufacturer,AddressWidth,MaxClockSpeed
		$bios = Get-CimInstance -ClassName Win32_BIOS -ComputerName $SiteServer | 
					Select-Object Name,Manufacturer,SerialNumber,ReleaseDate,SMBIOSBIOSVersion
		#$apps    = Get-CimInstance -ClassName Win32_Product -ComputerName $SiteServer
		#$updates = Get-CimInstance -ClassName Win32_QuickFixEngineering -ComputerName $SiteServer | Select-Object HotFixID,Description,InstalledOn
		$svcs = Get-CimInstance -ClassName Win32_Service -ComputerName $SiteServer |
					Select-Object Name,DisplayName,Description,StartMode,State,DelayedAutoStart,StartName
		$groups = Get-CimInstance -ClassName Win32_Group -ComputerName $SiteServer |
					Select-Object Name,Description,SID | Where-Object {$_.LocalAccount -eq $True}
		$users = Get-CimInstance -ClassName Win32_UserAccount -ComputerName $SiteServer |
					Select-Object Name,FullName,Description,Disabled,SID,LockOut,PasswordChangeable,PasswordExpires,PasswordRequired |
						Where-Object {$_.LocalAccount -eq $True}

		$svcusers = Get-LocalGroupMember -Group "Administrators" | 
			Where-Object {$_.ObjectClass -eq 'User'} | 
				Foreach-Object { 
					$pset = Get-CPrivilege $_.Name 
					[pscustomobject]@{
						Name = $_.Name
						Privileges = $pset -join ','
					}
				}
		$cs
		$os
		$disks
		$proc
		$bios
		$svcs
		$groups
		$users
		$svcusers
		#$apps
		#$updates
		<#
		sql instance
			version
			databases
			agent jobs
			files
			recovery model
			memory
			backups
		#>

		Get-DbaDbFile -
		Get-DbaSpn -ComputerName $SiteServer

		<#
		configmgr
			site type
			version
			site systems
			roles per system

		#>
	}
	catch {}
}