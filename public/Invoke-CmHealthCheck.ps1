[CmdletBinding()]
param(
	[parameter(Mandatory=$False)][string]$SiteCode = "P01",
	[parameter(Mandatory=$False)][string]$SiteServer = "cm01.contoso.local",
	[parameter(Mandatory=$False)][string]$SQLInstance = "cm01.contoso.local",
	[parameter(Mandatory=$False)][string]$DBName = "CM_P01",
	[parameter(Mandatory=$False)][string]$ClientName = "Contoso"
)
Import-Module cmhealth
$res = Test-CmHealth -SiteCode $SiteCode -Database $DBName -SiteServer $SiteServer -SqlInstance $SQLInstance -TestingScope All
$res | Out-CmHealthReport -ReportFile "$($env:USERPROFILE)\documents\cmhealth_$($ClientName)_detailed_$(Get-Date -f 'yyyyMMdd').htm" -Title "UHS" -Detailed
$res | Out-CmHealthReport -ReportFile "$($env:USERPROFILE)\documents\cmhealth_$($ClientName)_summary_$(Get-Date -f 'yyyyMMdd').htm" -Title "UHS"