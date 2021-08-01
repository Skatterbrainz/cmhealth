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
		'10.0.10240' { '1507' } # Windows 10
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
		'10.0.22000' { '21H1' } # Windows 11
		Default { 'unknown' }
	}
}