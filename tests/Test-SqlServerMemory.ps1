[CmdletBinding(SupportsShouldProcess = $True)]
param (
	[parameter(Mandatory)][ValidateNotNullOrEmpty()][hashtable] $ScriptParams

	[parameter(Mandatory = $False, HelpMessage = "SQL Instance Name")]
	[ValidateNotNullOrEmpty()]
	[string] $SqlServer = $(@($env:COMPUTERNAME, $env:USERDNSDOMAIN) -join '.'),
	[parameter(Mandatory = $False, HelpMessage = "Percent of Total PhysicalMemory")]
	[ValidateRange(80, 90)]
	[int32] $MaxAllocationPercent = 80,
	[parameter(Mandatory = $False, HelpMessage = "Apply remediation if needed")]
	[switch] $Remediate
)
$UnltdMemory = 2147483647
try {
	# get total memory allocated to SQL Server in MB
	$cmax = (Get-DbaMaxMemory -SqlInstance $ScriptParams.SqlInstance -EnableException -ErrorAction SilentlyContinue).MaxValue
	# get total physical memory of host in MB
	$tmem = (Get-DbaComputerSystem -ComputerName $ScriptParams.SqlInstance -EnableException -ErrorAction SilentlyContinue).TotalPhysicalMemory.Megabyte
	#$tmem = Get-WmiObject -Class Win32_ComputerSystem | Select -ExpandProperty TotalPhysicalMemory
	$target = $tmem * ($ScriptParams.MaxAllocationPercent / 100)
	$target = [math]::Round($target / 1MB, 0)
	if ($cmax -eq $UnltdMemory) {
		Write-Output "FAIL: current SQL Server max memory is unlimited. Should be $target MB"
		$modify = $True
	}
	else {
		if ($cmax -ne $target) {
			Write-Verbose "FAIL: current SQL Server max memory is constrained to $($cmax). Should be $target MB"
			$result = 'FAIL'
			$modify = $True
		}
		else {
			$result = 'PASS'
			Write-Verbose "PASS: current SQL Server max memory is constrained to $($cmax)"
		}
	}
	if ($modify) {
		if ($ScriptParams.Remediate) {
			Set-DbaMaxMemory -SqlInstance $ScriptParams.SqlInstance -Max $target -EnableException -ErrorAction SilentlyContinue
			Write-Verbose "REMEDIATE: SQL Server max memory is now set to $target MB"
			$result = 'REMEDIATED'
		}
	}
}
catch {
	Write-Error $Error[0].Exception.Message
	$result = 'ERROR'
}
finally {
	$result
}