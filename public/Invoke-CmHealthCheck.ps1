<#
.SYNOPSIS
	Auto-generate HTML reports for Test-CmHealth
.DESCRIPTION
	Generate an HTML report for both "summary" and "detailed" results by 
	invoking Test-CmHealth and sending the output to two report files
.PARAMETER SiteCode
	ConfigMgr site code
.PARAMETER SiteServer
	Name or FQDN of primary site server
.PARAMETER SQLInstance
	Name or FQDN of SQL instance/host
.PARAMETER DBName
	Name of ConfigMgr Database
.PARAMETER ClientName
	Name of customer or owner of the primary site
.EXAMPLE
	Invoke-CmHealthCheck -SiteCode P01 -SiteServer cm01.contoso.local -SQLInstance cm01.contoso.local -DBName CM_P01 -ClientName Contoso
	Generates "cmhealth_contoso_detailed_yyyyMMdd.htm" and "cmhealth_contoso_summary_yyyyMMdd.htm" both saved
	under the current user Documents folder ($($env:USERPROFILE)\Documents)
#>
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