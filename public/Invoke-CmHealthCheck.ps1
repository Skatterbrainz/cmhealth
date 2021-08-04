function Invoke-CmHealthCheck {
	[CmdletBinding()]
	param(
		[parameter(Mandatory=$True)][string]$SiteCode,
		[parameter(Mandatory=$True)][string]$SiteServer,
		[parameter(Mandatory=$True)][string]$SQLInstance,
		[parameter(Mandatory=$True)][string]$DBName,
		[parameter(Mandatory=$True)][string]$ClientName
	)
	Import-Module cmhealth
	$res = Test-CmHealth -SiteCode $SiteCode -Database $DBName -SiteServer $SiteServer -SqlInstance $SQLInstance -TestingScope All
	$res | Out-CmHealthReport -ReportFile "$($env:USERPROFILE)\documents\cmhealth_$($ClientName)_detailed_$(Get-Date -f 'yyyyMMdd').htm" -Title "UHS" -Detailed
	$res | Out-CmHealthReport -ReportFile "$($env:USERPROFILE)\documents\cmhealth_$($ClientName)_summary_$(Get-Date -f 'yyyyMMdd').htm" -Title "UHS"
}