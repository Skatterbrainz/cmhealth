# Updated for 0.3.12

function Import-CmHealthSettings {
	[CmdletBinding()]
	param (
		[parameter()][string] $Primary = "$($env:TEMP)\cmhealth.json",
		[parameter()][string] $Default = "$(Split-Path $(Get-Module cmhealth).Path)\reserve\cmhealth.json"
	)
	try {
		if (Test-Path $Primary) {
			Write-Log -Message "loading from: $Primary"
			$result = Get-Content -Path $Primary | ConvertFrom-Json
		} elseif (Test-Path $Default) {
			Write-Log -Message "loading from: $Default"
			$result = Get-Content -Path $Default | ConvertFrom-Json
		} else {
			throw "cmhealth.json was not found"
		}
	}
	catch {
		Write-Error $_.Exception.Message
	}
	finally {
		Write-Output $result
	}
}

function New-CmHealthConfig {
	[CmdletBinding()]
	param(
		[parameter(Mandatory=$False)][string]$Path = "$($env:TEMP)\cmhealth.json"
	)
	Write-Log -Message "Creating default cmhealth settings file at $Path"
	$mpath = Split-Path $(Get-Module cmhealth).Path
	$rpath = "$($mpath)\reserve"
	Write-Log -Message "source path is $rpath"
	$configFile = "$($rpath)\cmhealth.json"
	Write-Log -Message "destination path is $Path"
	Copy-Item -Path $configFile -Destination $Path -Force
	Write-Log -Message "cmhealth settings file saved as: $($Path)"
}

function Get-CmHealthDefaultValue {
	[CmdletBinding()]
	param (
		[parameter(Mandatory)][ValidateNotNullOrEmpty()][string] $KeySet,
		[parameter(Mandatory)][ValidateNotNullOrEmpty()] $DataSet
	)
	try {
		$keydef = $KeySet -split ':'
		if ($keydef.Count -gt 1) {
			$keyname = $keydef[0]
			$value   = $keydef[1]
			$result  = $DataSet."$keyname"."$value"
		} else {
			$result = $DataSet."$keydef"
		}
	}
	catch {
		Write-Error $_.Exception.Message
	}
	finally {
		Write-Output $result
	}
}

function Get-CmHealthLastTestSet {
	[CmdletBinding()]
	param(
		[parameter(Mandatory=$False)][string] $FilePath = "$($env:TEMP)\cmhealth-lastrun.txt"
	)
	if (Test-Path $FilePath) {
		Write-Log -Message "importing test selection from $FilePath"
		Write-Output $(Get-Content -Path $FilePath)
	} else {
		Write-Warning "Test history file not found: $FilePath"
	}
}

function Set-CmHealthLastTestSet {
	[CmdletBinding()]
	param(
		[parameter(Mandatory=$True)][string[]] $TestNames,
		[parameter(Mandatory=$False)][string] $FilePath = "$($env:TEMP)\cmhealth-lastrun.txt"
	)
	Write-Log -Message "saving test selection to $FilePath"
	$TestNames | Out-File -FilePath $FilePath -Force
}

function Get-CmSqlQueryResult {
	[CmdletBinding()]
	param (
		[parameter(Mandatory=$True)][ValidateNotNullOrEmpty()][string] $Query,
		[parameter(Mandatory=$True)] $Params
	)
	if ($null -ne $Params.Credential) {
		Write-Log -Message "submitting query with credentials"
		$result = @(Invoke-DbaQuery -SqlInstance $Params.SqlInstance -Database $Params.Database -Query $Query -SqlCredential $Params.Credential)
	} else {
		Write-Log -Message "submitting query without credentials"
		$result = @(Invoke-DbaQuery -SqlInstance $Params.SqlInstance -Database $Params.Database -Query $Query)
	}
	$result
}

function Get-WmiQueryResult {
	[CmdletBinding()]
	param (
		[parameter(Mandatory=$True)][string] $ClassName,
		[parameter(Mandatory=$False)][string] $Query = "",
		[parameter(Mandatory=$False)][string] $NameSpace = "root\cimv2",
		[parameter(Mandatory=$True)] $Params
	)
	if (![string]::IsNullOrEmpty($Params.Credential)) {
		Write-Log -Message "submitting WMI query with explicit credentials"
		Write-Log -Message "classname = $ClassName"
		$cs1 = New-CimSession -Credential $Params.Credential -Authentication Negotiate -ComputerName $Params.ComputerName -ErrorAction Stop
		if ([string]::IsNullOrEmpty($Query)) {
			$result = @(Get-CimInstance -CimSession $cs1 -ClassName $ClassName -Namespace $Namespace -ErrorAction Stop)
		} else {
			Write-Log -Message "query = $Query"
			$result = @(Get-CimInstance -CimSession $cs1 -ClassName $ClassName -Namespace $Namespace -Filter $Query -ErrorAction Stop)
		}
		$cs1 | Remove-CimSession
	} else {
		Write-Log -Message "submitting WMI query with implicit credentials"
		Write-Log -Message "classname = $ClassName"
		if ([string]::IsNullOrEmpty($Query)) {
			Write-Log -Message "no query. classname = $ClassName. namespace = $Namespace"
			[array]$result = Get-CimInstance -ClassName $ClassName -Namespace $Namespace -ErrorAction Stop
		} else {
			Write-Log -Message "query = $Query"
			[array]$result = Get-CimInstance -ClassName $ClassName -Namespace $Namespace -Filter $Query -ErrorAction Stop
		}
	}
	$result
}
function Get-RunTime {
	param (
		[parameter(Mandatory=$True)][datetime] $BaseTime
	)
	$NowTime = (Get-Date)
	$runTime = $(New-TimeSpan -Start $BaseTime -End $NowTime)
	$ret = $("{0}h:{1}m:{2}s:{3}ms" -f $($runTime | Foreach-Object {$_.Hours,$_.Minutes,$_.Seconds,$_.Milliseconds}))
	Write-Output $ret
}

function Convert-DecErrToHex {
	param (
		[parameter(Mandatory=$True)]$DecimalNumber
	)
	$n = [math]::Abs($DecimalNumber)
	Write-Output $('0x'+(++$n).ToString('X'))
}

# original from http://vcloud-lab.com/entries/powershell/powershell-get-registry-value-data
function Get-RegistryValueData {
	[CmdletBinding(SupportsShouldProcess=$True,
		ConfirmImpact='Medium',
		HelpURI='http://vcloud-lab.com')]
	Param ( 
		[parameter(Position=0, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)]
		[alias('C')]
		[String[]]$ComputerName = '.',
		[Parameter(Position=1, Mandatory=$True, ValueFromPipelineByPropertyName=$True)] 
		[alias('Hive')]
		[ValidateSet('ClassesRoot', 'CurrentUser', 'LocalMachine', 'Users', 'CurrentConfig')]
		[String]$RegistryHive = 'LocalMachine',
		[Parameter(Position=2, Mandatory=$True, ValueFromPipelineByPropertyName=$True)]
		[alias('KeyPath')]
		[String]$RegistryKeyPath = 'SYSTEM\CurrentControlSet\Services\USBSTOR',
		[parameter(Position=3, Mandatory=$True, ValueFromPipelineByPropertyName=$true)]
		[alias('Value')]
		[String]$ValueName = 'Start'
	)
	Begin {
		$RegistryRoot= "[{0}]::{1}" -f 'Microsoft.Win32.RegistryHive', $RegistryHive
		try {
			$RegistryHive = Invoke-Expression $RegistryRoot -ErrorAction Stop
		}
		catch {
			Write-Log -Message "incorrect registry hive referenced: $RegistryHive does not exist" -Category Warning -Show
		}
	}
	Process {
		Foreach ($Computer in $ComputerName) {
			Write-Log -Message "verifying connectivity to $computer"
			if ($computer -eq '.') {
				$reg = [Microsoft.Win32.RegistryKey]::OpenBaseKey($RegistryHive, 'default')
				$key = $reg.OpenSubKey($RegistryKeyPath)
				$Data = $key.GetValue($ValueName)
				[pscustomobject]@{
					Computer = $Computer
					RegistryValueName = "$RegistryKeyPath\$ValueName"
					RegistryValueData = $Data
				}
			} elseif (Test-Connection $computer -Count 2 -Quiet) {
				Write-Log -Message "keypath = $RegistryKeyPath - value = $ValueName"
				$reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($RegistryHive, $Computer)
				$key = $reg.OpenSubKey($RegistryKeyPath)
				$Data = $key.GetValue($ValueName)
				[pscustomobject]@{
					Computer = $Computer
					RegistryValueName = "$RegistryKeyPath\$ValueName"
					RegistryValueData = $Data
				}
			}
			else {
				Write-Log -Message "$Computer not reachable" -Category Warning -Show
			}
		}
	}
	End {
		#[Microsoft.Win32.RegistryHive]::ClassesRoot
		#[Microsoft.Win32.RegistryHive]::CurrentUser
		#[Microsoft.Win32.RegistryHive]::LocalMachine
		#[Microsoft.Win32.RegistryHive]::Users
		#[Microsoft.Win32.RegistryHive]::CurrentConfig
	}
}

# returns 4-digit ConfigMgr site version build number (e.g. "9045")
function Get-CmBuildNumber {
	[CmdletBinding()]
	param (
		[parameter(Mandatory=$False)][string]$ComputerName = '.'
	)
	$cmv = Get-RegistryValueData -ComputerName $ComputerName -RegistryHive LocalMachine -RegistryKeyPath SOFTWARE\Microsoft\SMS\Setup -ValueName 'Version'
	Write-Output $($cmv | Select-Object -ExpandProperty RegistryValueData)
}

function Get-CmVersionName {
	param(
		[parameter(Mandatory=$True)][string] $Version
	)
	Write-Log -Message "querying configuration manager version name"
	$mpath = $(Get-Module cmhealth -ListAvailable).Path | Select-Object -First 1
	$fpath = $(Join-Path -Path $(Split-Path $mpath) -ChildPath "private\buildnumbers_cm.csv")
	Write-Log -Message "reading file $fpath"
	if (Test-Path $fpath) {
		$csvdata = Import-Csv -Path $fpath
		$build = $csvdata | Where-Object {$_.Build -eq $Version} | Select-Object -ExpandProperty Name
		Write-Output $build
	} else {
		Write-Log -Message "file not found! $fpath" -Category Warning
	}
}

function Write-Log {
	param (
		[parameter(Mandatory=$False)][string]$Message = "",
		[parameter(Mandatory=$False)][string][ValidateSet('Info','Warning','Error')]$Category = "Info",
		[parameter(Mandatory=$False)][switch]$Show,
		[parameter(Mandatory=$False)][switch]$ClearLog
	)
	$msg = "$(Get-Date -f 'yyyy-MM-dd hh:mm:ss') - $Category - $Message"
	if ($ClearLog) {
		$msg | Out-File -FilePath $LogFile -Force
	} else {
		$msg | Out-File -FilePath $LogFile -Append
	}
	if ($Show) { 
		switch ($Category) {
			'Error' { Write-Host $msg -ForegroundColor Red }
			'Warning' { Write-Host $msg -ForegroundColor Yellow }
			Default { Write-Host $msg -ForegroundColor Cyan }
		}
	}
}

function Get-WindowsBuildNumber {
	param(
		[parameter(Mandatory=$True)][string] $Version
	)
	switch ($Version) {
		'10.0.10240' { '1507' }
		'10.0.10586' { '1511' }
		'10.0.14393' { '1607' }
		'10.0.15063' { '1703' }
		'10.0.16299' { '1709' }
		'10.0.17134' { '1803' }
		'10.0.17763' { '1809' }
		'10.0.18362' { '1903' }
		'10.0.18363' { '1909' }
		'10.0.19041' { '2004' }
		'10.0.19042' { '20H2' }
		'10.0.19043' { '21H1' }
		'10.0.19044' { '21H2' }
		'10.0.22000' { '21H1' }
		Default { 'unknown' }
	}
}

<#
CREDIT to Trevor Jones for this function as part of the script that queries
site status messages. Refer to https://smsagent.blog/2015/07/22/retrieving-configmgr-status-messages-with-powershell/
#>
function Get-StatusMessage {
	param (
		$SmsMsgsPath,
		$iMessageID,
		[ValidateSet("srvmsgs.dll","provmsgs.dll","climsgs.dll")]$DLL,
		[ValidateSet("Informational","Warning","Error")]$Severity,
		$InsString1,
		$InsString2,
		$InsString3,
		$InsString4,
		$InsString5,
		$InsString6,
		$InsString7,
		$InsString8,
		$InsString9,
		$InsString10
	)
	 
	if ($DLL -eq "srvmsgs.dll")	{ $stringPathToDLL = "$SMSMSGSLocation\srvmsgs.dll" }
	if ($DLL -eq "provmsgs.dll") { $stringPathToDLL = "$SMSMSGSLocation\provmsgs.dll" }
	if ($DLL -eq "climsgs.dll") { $stringPathToDLL = "$SMSMSGSLocation\climsgs.dll" }
	 
	#Load Status Message Lookup DLL into memory and get pointer to memory
	$ptrFoo = $Win32LoadLibrary::LoadLibrary($stringPathToDLL.ToString())
	$ptrModule = $Win32GetModuleHandle::GetModuleHandle($stringPathToDLL.ToString()) 
	 
	if ($Severity -eq "Informational") { $code = 1073741824 }
	if ($Severity -eq "Warning") { $code = 2147483648 }
	if ($Severity -eq "Error") { $code = 3221225472 }
	 
	$result = $Win32FormatMessage::FormatMessage($flags, $ptrModule, $Code -bor $iMessageID, 0, $stringOutput, $sizeOfBuffer, $stringArrayInput)
	if ($result -gt 0) {
		# Add insert strings to message
		$objMessage = New-Object System.Object
		$objMessage | Add-Member -type NoteProperty -name MessageString -value $stringOutput.ToString().Replace("%11","").Replace("%12","").Replace("%3%4%5%6%7%8%9%10","").Replace("%1",$InsString1).Replace("%2",$InsString2).Replace("%3",$InsString3).Replace("%4",$InsString4).Replace("%5",$InsString5).Replace("%6",$InsString6).Replace("%7",$InsString7).Replace("%8",$InsString8).Replace("%9",$InsString9).Replace("%10",$InsString10)
	}
	$objMessage
}

<#
CREDIT to Trevor Jones for this function as part of the script that queries
site status messages. Refer to https://smsagent.blog/2015/07/22/retrieving-configmgr-status-messages-with-powershell/
The only real modification was to replace the ADO.NET code using module DbaTools: Invoke-DbaQuery
#>

function Get-SiteStatusMessages {
	[CmdletBinding()]
	param ($Params)
	try {
		# get installation path to determine smsmsgs DLL path
		$site =Get-CimInstance -ClassName SMS_Site -ComputerName $Params.ComputerName -Namespace "root/sms/site_$($Params.SiteCode)"
		if ($null -ne $site.InstallDir) {
			$SMSMSGSLocation = "$($site.InstallDir)\bin\X64\system32\smsmsgs"
		} else {
			throw "unable to get installation path"
		}
		$Query = "
select smsgs.RecordID,
CASE smsgs.Severity
WHEN -1073741824 THEN 'Error'
WHEN 1073741824 THEN 'Informational'
WHEN -2147483648 THEN 'Warning'
ELSE 'Unknown'
END As 'SeverityName',
case smsgs.MessageType
WHEN 256 THEN 'Milestone'
WHEN 512 THEN 'Detail'
WHEN 768 THEN 'Audit'
WHEN 1024 THEN 'NT Event'
ELSE 'Unknown'
END AS 'Type',
smsgs.MessageID, smsgs.Severity, smsgs.MessageType, smsgs.ModuleName,modNames.MsgDLLName, smsgs.Component,
smsgs.MachineName, smsgs.Time, smsgs.SiteCode, smwis.InsString1,
smwis.InsString2, smwis.InsString3, smwis.InsString4, smwis.InsString5,
smwis.InsString6, smwis.InsString7, smwis.InsString8, smwis.InsString9,
smwis.InsString10
from v_StatusMessage smsgs
join v_StatMsgWithInsStrings smwis on smsgs.RecordID = smwis.RecordID
join v_StatMsgModuleNames modNames on smsgs.ModuleName = modNames.ModuleName
where smsgs.MachineName = '$($Params.ComputerName)'
and DATEDIFF(hour,smsgs.Time,GETDATE()) < '$TimeInHours'
Order by smsgs.Time DESC
"

		$table = Invoke-DbaQuery -SqlInstance $Params.SqlInstance -Database $Params.Database -Query $Query

#Start PInvoke Code
$sigFormatMessage = @'
[DllImport("kernel32.dll")]
public static extern uint FormatMessage(uint flags, IntPtr source, uint messageId, uint langId, StringBuilder buffer, uint size, string[] arguments);
'@ 
 
$sigGetModuleHandle = @'
[DllImport("kernel32.dll")]
public static extern IntPtr GetModuleHandle(string lpModuleName);
'@ 
 
$sigLoadLibrary = @'
[DllImport("kernel32.dll")]
public static extern IntPtr LoadLibrary(string lpFileName);
'@ 
 
		$Win32FormatMessage = Add-Type -MemberDefinition $sigFormatMessage -Name "Win32FormatMessage" -Namespace Win32Functions -PassThru -Using System.Text
		$Win32GetModuleHandle = Add-Type -MemberDefinition $sigGetModuleHandle -Name "Win32GetModuleHandle" -Namespace Win32Functions -PassThru -Using System.Text
		$Win32LoadLibrary = Add-Type -MemberDefinition $sigLoadLibrary -Name "Win32LoadLibrary" -Namespace Win32Functions -PassThru -Using System.Text
		#End PInvoke Code 
 
		$sizeOfBuffer = [int]16384
		$stringArrayInput = {"%1","%2","%3","%4","%5", "%6", "%7", "%8", "%9"}
		$flags = 0x00000800 -bor 0x00000200
		$stringOutput = New-Object System.Text.StringBuilder $sizeOfBuffer 
 
		$StatusMessages = @()
		foreach ($Row in $Table) {
			$Params = @{
				SmsMsgsPath = $SMSMSGSLocation
				iMessageID  = $Row.MessageID
				DLL         = $Row.MsgDLLName
				Severity    = $Row.SeverityName
				InsString1  = $Row.InsString1
				InsString2  = $Row.InsString2
				InsString3  = $Row.InsString3
				InsString4  = $Row.InsString4
				InsString5  = $Row.InsString5
				InsString6  = $Row.InsString6
				InsString7  = $Row.InsString7
				InsString8  = $Row.InsString8
				InsString9  = $Row.InsString9
				InsString10 = $Row.InsString10
			}
			$Message = Get-StatusMessage @params
 
			$StatusMessage = New-Object psobject
			Add-Member -InputObject $StatusMessage -Name Severity -MemberType NoteProperty -Value $Row.SeverityName
			Add-Member -InputObject $StatusMessage -Name Type -MemberType NoteProperty -Value $Row.Type
			Add-Member -InputObject $StatusMessage -Name SiteCode -MemberType NoteProperty -Value $Row.SiteCode
			Add-Member -InputObject $StatusMessage -Name DateTime -MemberType NoteProperty -Value $Row.Time
			Add-Member -InputObject $StatusMessage -Name System -MemberType NoteProperty -Value $Row.MachineName
			Add-Member -InputObject $StatusMessage -Name Component -MemberType NoteProperty -Value $Row.Component
			Add-Member -InputObject $StatusMessage -Name Module -MemberType NoteProperty -Value $Row.ModuleName
			Add-Member -InputObject $StatusMessage -Name MessageID -MemberType NoteProperty -Value $Row.MessageID
			Add-Member -InputObject $StatusMessage -Name Description -MemberType NoteProperty -Value $Message.MessageString
			$StatusMessages += $StatusMessage
		}
		$StatusMessages
	}
	catch {
		Write-Error $_.Exception.Message 
	}
}

function Test-CmHealthModuleVersion {
	param()
	try {
		$mv = Get-Module 'cmhealth' -ListAvailable | Select-Object -First 1 -ExpandProperty Version
		if ($null -ne $mv) {
			$mv = $mv -join '.'
			$fv = Find-Module 'cmhealth' | Select-Object -ExpandProperty Version
			if ([version]$fv -gt [version]$mv) {
				Write-Warning "cmhealth $mv is installed. $fv is available"
			} else {
				Write-Host "cmhealth version $mv is the latest available" -ForegroundColor Cyan
			}
		} else {
			Write-Warning "cmhealth version could not be determined"
		}
	}
	catch {
		Write-Error $_.Exception.Message
	}
}

function Test-CmHealthDependentModules {
	param()
	Write-Host "checking module dependencies for latest versions..." -ForegroundColor Cyan
	try {
		foreach ($module in ('dbatools','carbon','adsips','pswindowsupdate')) {
			$mv = Get-Module $module -ListAvailable | Select-Object -First 1 -ExpandProperty Version 
			if ($null -ne $mv) {
				$mv = $mv -join '.'
				$fv = Find-Module $module | Select-Object -ExpandProperty Version
				if ([version]$fv -gt [version]$mv) {
					Write-Warning "$module version $mv is installed. $fv is available."
				} else {
					Write-Host "$module version $mv is the latest version." -ForegroundColor Cyan
				}
			} else {
				Write-Warning "$module is not installed or could not be located on this computer."
			}
		}
	}
	catch {
		Write-Error $_.Exception.Message
	}
}