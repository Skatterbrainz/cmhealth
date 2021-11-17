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
.PARAMETER OutputFolder
	Path where output (report) files will be created
.EXAMPLE
	Invoke-CmHealthTests -SiteCode P01 -SiteServer cm01.contoso.local -SQLInstance cm01.contoso.local -DBName CM_P01 -ClientName Contoso
	Generates "cmhealth_contoso_detailed_yyyyMMdd.htm" and "cmhealth_contoso_summary_yyyyMMdd.htm" both saved
	under the current user Documents folder ($($env:USERPROFILE)\Documents)
.EXAMPLE
	Invoke-CmHealthTests -SiteCode P01 -SiteServer cm01.contoso.local -SQLInstance cm01.contoso.local -DBName CM_P01 -ClientName Contoso -OutputFolder c:\windows\temp
	Generates "cmhealth_contoso_detailed_yyyyMMdd.htm" and "cmhealth_contoso_summary_yyyyMMdd.htm" both saved
	under C:\Windows\Temp
.NOTES
	Thank you!
.LINK
	https://github.com/Skatterbrainz/cmhealth/blob/master/docs/Invoke-CmHealthTests.md
#>
function Invoke-CmHealthTests {
	[CmdletBinding()]
	param(
		[parameter(Mandatory=$True)][string]$SiteCode,
		[parameter(Mandatory=$True)][string]$SiteServer,
		[parameter(Mandatory=$True)][string]$SQLInstance,
		[parameter(Mandatory=$True)][string]$DBName,
		[parameter(Mandatory=$True)][string]$ClientName,
		[parameter(Mandatory=$False)][string]$OutputFolder = "$($env:USERPROFILE)\documents"
	)
	Import-Module cmhealth
	$res = Test-CmHealth -SiteCode $SiteCode -Database $DBName -SiteServer $SiteServer -SqlInstance $SQLInstance -TestingScope All
	Write-Verbose "determining report file names and location"
	$report1 = Join-Path -Path $OutputFolder -ChildPath "cmhealth_$($ClientName)_detailed_$(Get-Date -f 'yyyyMMdd').htm"
	$report2 = Join-Path -Path $OutputFolder -ChildPath "cmhealth_$($ClientName)_summary_$(Get-Date -f 'yyyyMMdd').htm"
	Write-Verbose "exporting detailed and summary report files"
	$res | Out-CmHealthReport -ReportFile $report1 -Title $ClientName -Detailed
	$res | Out-CmHealthReport -ReportFile $report2 -Title $ClientName
	Write-Host "Report files saved to folder: $OutputFolder"
}