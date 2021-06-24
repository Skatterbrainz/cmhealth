<#
.SYNOPSIS
	Export HTML healthcheck report
.DESCRIPTION
	Export HTML healthcheck report from results captured by Test-CmHealth
.PARAMETER TestData
	Health test data, returned from Test-CmHealth
.PARAMETER Path
	HTML file path and name. Default is "cmhealthreport-YYYY-MM-DD.htm"
	The default path location is $env:Temp
.PARAMETER Title
	Title for report heading. Default is "MECM"
.PARAMETER CssFile
	Path to custom CSS stylesheet file. If not provided, internal CSS is used by default.
.PARAMETER Status
	Filter results by status type: All, Fail, Pass, Warning, Error (default is All)
.PARAMETER Detailed
	Show test output data in report
.PARAMETER Show
	Open HTML report when complete
.PARAMETER LogFile
	Path and name of Log file. If Test-CmHealth has been invoked during the same PowerShell 
	session, the LogFile will use the same filename and path. The default path is $env:Temp
.EXAMPLE
	$testresult = Test-CmHealth -SiteCode P01 -Database CM_P01
	$testresult | Out-CmHealthReport -Show
.EXAMPLE
	Test-CmHealth -SiteCode P01 -Database CM_P01 | Out-CmHealthReport -Status Fail -Show
.EXAMPLE
	Test-CmHealth -SiteCode P01 -Database CM_P01 | Out-CmHealthReport -Status Fail -Detailed -Show
.LINK
	https://github.com/Skatterbrainz/cmhealth/blob/master/docs/Out-CmHealthReport.md
.NOTES
	Thank you!
#>

function Out-CmHealthReport {
	[CmdletBinding()]
	param (
		[parameter(Mandatory=$True, ValueFromPipeline=$True)]$TestData,
		[parameter(Mandatory=$False)][string]$ReportFile = "$($env:TEMP)\cmhealthreport-$(Get-Date -f 'yyyy-MM-dd').htm",
		[parameter(Mandatory=$False)][string][ValidateSet('All','Fail','Pass','Warning','Error','NonPassing')] $Status = 'All',
		[parameter(Mandatory=$False)][string]$Title = "MECM",
		[parameter(Mandatory=$False)][string]$CssFile = "",
		[parameter(Mandatory=$False)][switch]$Detailed,
		[parameter(Mandatory=$False)][switch]$Show,
		[parameter(Mandatory=$False)][string]$Footer = "",
		[parameter(Mandatory=$False)][string]$LogFile = "$($env:TEMP)\cmhealth_$(Get-Date -f 'yyyy-MM-dd').log"
	)
	BEGIN {
		Write-Log -Message "defining HTML properties"
		$tablewidth = "800px"
		$leftpanel  = "150px"
		if ($Status -ne 'All') {
			Write-Log -Message "filtering test data for status = $Status"
			$TestData = $TestData | Where-Object {$_.Status -eq $Status}
		}
		Write-Log -Message "processing test data"
	}
	PROCESS {
		#$summary = $TestData | Group-Object Status | Select-Object Name,Count,Group
		if ($Status -eq 'NonPassing') {
			$inputData = $TestData | Where-Object {$_.Status -ne 'PASS'}
		} elseif ($Status -ne 'All') {
			$inputData = $TestData | Where-Object {$_.Status -eq $Status}
		} else {
			$inputData = $TestData
		}
		foreach ($item in $inputData) {
			$tname  = $item.TestName
			$tdesc  = $item.Description
			$tgroup = $item.TestGroup
			$tmsg   = $item.Message
			$tstat  = $item.Status
			switch ($tstat) {
				'PASS' { $tstat = "<span style=color:green>$tstat</span>"}
				'FAIL' { $tstat = "<span style=color:red>$tstat</span>"}
				'WARNING' { $tstat = "<span style=color:orange>$tstat</span>"}
				'ERROR' { $tstat = "<span style=color:red>$tstat</span>"}
			}
			$trun   = $item.RunTime
			if ($Detailed) {
				$tdata  = $item.TestData | ConvertTo-Html -Fragment
			}
			$chunk  = $item | foreach-object {
				if ($Detailed) {
@"
<h2>$($tName)</h2>
<table width=$tablewidth>
<tr><td width=$leftpanel>Description</td><td>$($tDesc)</td></tr>
<tr><td>Group</td><td>$($tgroup)</td></tr>
<tr><td>Test Result</td><td>$($tstat)</td></tr>
<tr><td>Message</td><td>$($tmsg)</td></tr>
<tr><td>Runtime</td><td>$($trun)</td></tr>
<tr><td>Output</td><td>$($tdata)</td></tr>
</table>
"@
				} else {
@"
<h2>$($tName)</h2>
<table width=$tablewidth>
<tr><td width=$leftpanel>Description</td><td>$($tDesc)</td></tr>
<tr><td>Group</td><td>$($tgroup)</td></tr>
<tr><td>Test Result</td><td>$($tstat)</td></tr>
<tr><td>Message</td><td>$($tmsg)</td></tr>
<tr><td>Runtime</td><td>$($trun)</td></tr>
</table>
"@
				}
			}
			$body += $chunk
		} # foreach
	}
	END {
		#$stats = $inputData | Group-Object Status | Select-Object Name,Count,Group
		if ([string]::IsNullOrEmpty($CssFile)) {
			Write-Log -Message "using default CSS"
			$styles = @"
<style>
BODY {background-color:#CCCCCC;font-family:Calibri,sans-serif; font-size: small;}
TABLE {border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse; width: 98%;}
TH {border-width: 1px;padding: 0px;border-style: solid;border-color: black;background-color:#293956;color:white;padding: 5px; font-weight: bold;text-align:left;}
TD {border-width: 1px;padding: 0px;border-style: solid;border-color: black;background-color:#F0F0F0; padding: 2px;}
</style>
"@
		} else {
			Write-Log -Message "importing CSS from file: $CssFile"
			if (Test-Path $CssFile) {
				$cssdata = Get-Content -Path $CssFile
				$styles = "<style>$cssdata</style>"
			}
		}
		Write-Log -Message "combining output to HTML"
		if ($null -ne $GLOBAL:CmhParams) {
			$Title += " $(($GLOBAL:CmhParams).SiteCode)"
		}
		$mversion = (Get-Module cmhealth -ListAvailable | Select-Object -First 1).Version -join '.'
		$heading = "<h1>Configuration Manager Site Health Report - $Title</h1>"
		$prelim = "<p>$($env:COMPUTERNAME) - $(Get-Date) - $($env:USERNAME)</p>"
		$prelim += "<p>CMHealth version $mversion</p>"
		if (![string]::IsNullOrEmpty($Footer)) {
			$Footer = "<p>$($Footer)</p>"
		}
		$body = $heading + $prelim + $body + $Footer
		$report = "Health Report" | ConvertTo-Html -Title "Health Report" -Body $body -Head $styles
		Write-Host "exporting data to $ReportFile"
		$report | Out-File $ReportFile -Force
		if ($Show) { Start-Process $ReportFile }
	}
}