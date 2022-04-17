function Invoke-CmHealthTests {
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
[CmdletBinding()]
	[OutputType()]
	param(
		[parameter(Mandatory=$True)][string]$SiteCode,
		[parameter(Mandatory=$True)][string]$SiteServer,
		[parameter(Mandatory=$True)][string]$SQLInstance,
		[parameter(Mandatory=$True)][string]$DBName,
		[parameter(Mandatory=$True)][string]$ClientName,
		[parameter(Mandatory=$False)][string]$OutputFolder = "$($env:USERPROFILE)\documents",
		[parameter(Mandatory=$False)][switch]$NoVersionCheck
	)
	Import-Module cmhealth
	$tparams = @{
		SiteCode = $SiteCode
		Database = $DBName
		SiteServer = $SiteServer
		SqlInstance = $SQLInstance
		TestingScope = 'All'
		NoVersionCheck = $NoVersionCheck
	}
	$res = Test-CmHealth @tparams
	Write-Verbose "exporting detailed and summary report files"
	$res | Out-CmHealthReport -Title $ClientName -Footer $ClientName -Detailed -OutputFolder $OutputFolder
	$res | Out-CmHealthReport -Title $ClientName -Footer $ClientName -OutputFolder $OutputFolder
	Write-Host "Report files saved to folder: $OutputFolder"
}