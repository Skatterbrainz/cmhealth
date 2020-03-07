function Get-SqlIndexFragmentation {
	[CmdletBinding()]
	param (
		[parameter(Mandatory)][string]$SqlInstance,
		[parameter(Mandatory)][string]$Database,
		[parameter()][int] $MinValue = 50
	)
	$query = "SELECT dbschemas.[name] as 'Schema',
dbtables.[name] as 'Table',
dbindexes.[name] as 'Index',
indexstats.avg_fragmentation_in_percent,
indexstats.page_count
FROM sys.dm_db_index_physical_stats (DB_ID(), NULL, NULL, NULL, NULL) AS indexstats
INNER JOIN sys.tables dbtables on dbtables.[object_id] = indexstats.[object_id]
INNER JOIN sys.schemas dbschemas on dbtables.[schema_id] = dbschemas.[schema_id]
INNER JOIN sys.indexes AS dbindexes ON dbindexes.[object_id] = indexstats.[object_id]
AND indexstats.index_id = dbindexes.index_id
WHERE indexstats.database_id = DB_ID() and indexstats.avg_fragmentation_in_percent > $MinValue
ORDER BY indexstats.avg_fragmentation_in_percent desc"

	$result = (Invoke-DbaQuery -SqlInstance $SqlInstance -Database $Database -Query $query | ForEach-Object {
			[pscustomobject]@{
				Schema = $_.Schema
				Table  = $_.Table 
				Index  = $_.Index
				AvgFragPct = [math]::Round($_.avg_fragmentation_in_percent,2)
				PageCount  = $_.PageCount
			}
		})
	, $result
}

function Get-CmDeviceSummary {
	param (
		[parameter(Mandatory)][string] $SqlInstance,
		[parameter(Mandatory)][string] $Database
	)
	$query = "select * from v_CombinedDeviceResources where (name not like '%unknown%') and (name not like '%provisioning device%') order by name"
	$result = (Invoke-DbaQuery -SqlInstance $SqlInstance -Database $Database -Query $query | 
		Select-Object Name,MachineID,SerialNumber,MACAddress,DeviceOS,DeviceOSBuild,CoManaged,ClientVersion,IsVirtualMachine,ADSiteName,LastMPServerName,LastPolicyRequest,LastDDR,LastHardwareScan,LastSoftwareScan,LastActiveTime,LastClientCheckTime,ClientCheckPass)
	, $result

}
function Get-CmClientCoverage {
	param (
		[parameter(Mandatory)][string] $SqlInstance,
		[parameter(Mandatory)][string] $Database
	)
	$query = "select distinct COALESCE(Client_Version0,'NONE'), count(*) as Qty from v_r_system group by Client_Version0"
	, @(Invoke-DbaQuery -SqlInstance $SqlInstance -Database $Database -query $query)
}

function Get-ServiceAccountPrivileges {
	[CmdletBinding()]
	param (
		[parameter(Mandatory)][string] $ComputerName
	)
	$privs = ('SeServiceLogonRight','SeAssignPrimaryTokenPrivilege','SeChangeNotifyPrivilege','SeIncreaseQuotaPrivilege')
	try {
		$mpath = Split-Path (Get-Module CMhealth).Path -Parent
		$jfile = "$mpath\services.json"
		if (!(Test-Path $jfile)) { throw "file not found: $jfile" }
		Write-Verbose "loading configuration file: $jfile"
		$jdata = Get-Content $jfile | ConvertFrom-Json
		$jdata.Services | ForEach-Object {
			$svcName = $_.Name 
			$svcRef  = $_.Reference 
			$privs   = $_.Privileges
			Write-Verbose "service name: $svcName"
			try {
				$svcAcct = Get-CimInstance -ClassName Win32_Service -Filter "Name = '$svcName'" | Select-Object -ExpandProperty StartName
				Write-Host "checking service account: $svcAcct"
				$cprivs = Get-CPrivilege -Identity $svcAcct
				$privs -split ',' | Foreach-Object { 
					$priv = $_
					if ($priv -notin $cprivs) { $res = 'FAIL' } else { $res = 'PASS' } 
					[pscustomobject]@{
						ServiceName = $svcName
						ServiceUser = $svcAcct
						Reference   = $svcRef
						Privilege   = $priv
						Compliant   = $res
					}
				}
			}
			catch {
				Write-Error $_.Exception.Message
			}
		}
	}
	catch {
		Write-Error $_.Exception.Message
	}
}

function Get-CmHealth {
	[CmdletBinding()]
	param (
		[parameter(Mandatory)][ValidateNotNullOrEmpty()][string] $SiteServer,
		[parameter(Mandatory)][ValidateLength(3,3)][string] $SiteCode,
		[parameter()][string] $OutputFolder = "$($env:USERPROFILE)\Documents"
	)
	$filepath = "$OutputFolder\$SiteServer`_$(Get-Date -f 'yyyy-MM-dd').htm"
	Write-Verbose "report file: $filepath"
	try {
		Write-Host "Gathering data from site server $SiteServer" -ForegroundColor Cyan
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
					Select-Object DeviceID,Size,FreeSpace,FileSystem,VolumeName,DriveType,NumberOfBlocks |
						Sort-Object DeviceID
		$proc = Get-CimInstance -ClassName Win32_Processor -ComputerName $SiteServer |
					Select-Object Name,Description,Manufacturer,AddressWidth,MaxClockSpeed
		$bios = Get-CimInstance -ClassName Win32_BIOS -ComputerName $SiteServer | 
					Select-Object Name,Manufacturer,SerialNumber,ReleaseDate,SMBIOSBIOSVersion
		$apps    = Get-CimInstance -ClassName Win32_Product -ComputerName $SiteServer |
					Select-Object Name,Version,Vendor,IdentifyingNumber,InstallDate,InstallDate2,InstallLocation,InstallSource,LocalPackage,PackageName,HelpLink |
						Sort-Object Name
		$updates = Get-CimInstance -ClassName Win32_QuickFixEngineering -ComputerName $SiteServer | 
					Select-Object HotFixID,Description,InstalledOn |
						Sort-Object HotFixID
		$svcs = Get-CimInstance -ClassName Win32_Service -ComputerName $SiteServer |
					Select-Object Name,DisplayName,Description,StartMode,State,DelayedAutoStart,StartName |
						Sort-Object Name
		$groups = Get-CimInstance -ClassName Win32_Group -ComputerName $SiteServer |
					Select-Object Name,Description,SID | Where-Object {$_.LocalAccount -eq $True} |
						Sort-Object Name
		$users = Get-CimInstance -ClassName Win32_UserAccount -ComputerName $SiteServer |
					Select-Object Name,FullName,Description,Disabled,SID,LockOut,PasswordChangeable,PasswordExpires,PasswordRequired |
						Where-Object {$_.LocalAccount -eq $True} |
							Sort-Object Name

		$svcusers = Get-LocalGroupMember -Group "Administrators" | 
			Where-Object {$_.ObjectClass -eq 'User'} | 
				Foreach-Object { 
					$pset = Get-CPrivilege $_.Name 
					[pscustomobject]@{
						Name = $_.Name
						Privileges = $pset -join ','
					}
				}
		
		Write-Host "Compiling report..." -ForegroundColor Cyan
		$output = @()
		$output += "<h2>Computer System</h2>$($cs | ConvertTo-HTML -Fragment)"
		$output += "<h2>Operating System</h2>$($os | ConvertTo-HTML -Fragment)"
		$output += "<h2>Logical Disks</h2>$($disks | ConvertTo-HTML -Fragment)"
		$output += "<h2>Processors</h2>$($proc | ConvertTo-HTML -Fragment)"
		$output += "<h2>BIOS</h2>$($bios | ConvertTo-HTML -Fragment)"
		$output += "<h2>Services</h2>$($svcs | ConvertTo-HTML -Fragment)"
		$output += "<h2>Local Groups</h2>$($groups | ConvertTo-HTML -Fragment)"
		$output += "<h2>Local Users</h2>$($users | ConvertTo-HTML -Fragment)"
		$output += "<h2>Special Administrators</h2>$($svcusers | ConvertTo-HTML -Fragment)"
		$output += "<h2>Installed Software</h2>$($apps | ConvertTo-HTML -Fragment)"
		$output += "<h2>Installed Updates</h2>$($updates | ConvertTo-HTML -Fragment)"
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

		#Get-DbaDbFile -
		#Get-DbaSpn -ComputerName $SiteServer

		<#
		configmgr
			site type
			version
			site systems
			roles per system

		#>
		Write-Verbose "converting content to HTML..."
		$body = $output -join '' | ConvertTo-Html -Fragment
		Write-Host "Saving report to file: $filepath" -ForegroundColor Cyan
		ConvertTo-HTML -InputObject $body -Title "MECM Health Report: $SiteServer" -CssUri ".\default.css" |
			Out-File -FilePath $filepath -Force
		Write-Host "Opening report in browser..." -ForegroundColor Cyan
		Start-Process $filepath
	}
	catch {}
}