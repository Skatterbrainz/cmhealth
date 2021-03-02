<#
.SYNOPSIS
	Export HTML report
.DESCRIPTION
	Export HTML health test report
.PARAMETER TestData
	Health test data, returned from Test-CmHealth
.PARAMETER Path
	HTML file path
.PARAMETER Status
	Filter results by status type: All, Fail, Pass, Warning, Error (default is All)
.PARAMETER Detailed
	Show test output data in report
.PARAMETER Show
	Open HTML report when complete
.EXAMPLE
	$testresult = Test-CmHealth -SiteCode P01 -Database CM_P01
	$testresult | Out-HealthReport -Show
.EXAMPLE
	Test-CmHealth -SiteCode P01 -Database CM_P01 | Out-HealthReport -Status Fail -Show
.EXAMPLE
	Test-CmHealth -SiteCode P01 -Database CM_P01 | Out-HealthReport -Status Fail -Detailed -Show
.LINK
	https://github.com/Skatterbrainz/cmhealth/blob/master/docs/Out-HealthReport.md
.NOTES
	Released with 0.2.24
#>

function Out-HealthReport {
	[CmdletBinding()]
	param (
		[parameter(Mandatory=$True, ValueFromPipeline=$True)]$TestData,
		[parameter(Mandatory=$False)][string]$Path = "$($env:TEMP)\healthreport.htm",
		[parameter(Mandatory=$False)][string][ValidateSet('All','Fail','Pass','Warning','Error')] $Status = 'All',
		[parameter(Mandatory=$False)][string]$Title = "ConfigMgr Site",
		[parameter(Mandatory=$False)][string]$CssFile = "",
		[parameter(Mandatory=$False)][switch]$Detailed,
		[parameter(Mandatory=$False)][switch]$Show
	)
	BEGIN {
		Write-Verbose "defining HTML properties"
		$tablewidth = "800px"
		$leftpanel  = "150px"
		if ($Status -ne 'All') {
			Write-Verbose "filtering test data for status = $Status"
			$TestData = $TestData | Where-Object {$_.Status -eq $Status}
		}
		Write-Verbose "processing test data"
	}
	PROCESS {
		#$summary = $TestData | Group-Object Status | Select-Object Name,Count,Group
		if ($Status -ne 'All') {
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
		$stats = $inputData | Group-Object Status | Select-Object Name,Count,Group
		if ([string]::IsNullOrEmpty($CssFile)) {
			Write-Verbose "using default CSS"
			$styles = @"
<style>
BODY {background-color:#CCCCCC;font-family:Calibri,sans-serif; font-size: small;}
TABLE {border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse; width: 98%;}
TH {border-width: 1px;padding: 0px;border-style: solid;border-color: black;background-color:#293956;color:white;padding: 5px; font-weight: bold;text-align:left;}
TD {border-width: 1px;padding: 0px;border-style: solid;border-color: black;background-color:#F0F0F0; padding: 2px;}
</style>
"@
		} else {
			Write-Verbose "importing CSS from file: $CssFile"
			if (Test-Path $CssFile) {
				$cssdata = Get-Content -Path $CssFile
				$styles = "<style>$cssdata</style>"
			}
		}
		Write-Verbose "combining output to HTML"
		if ($null -ne $GLOBAL:CmhParams) {
			$Title += " $(($GLOBAL:CmhParams).SiteCode)"
		}
		$mversion = (Get-Module cmhealth -ListAvailable).Version -join '.'
		$heading = "<h1>Health Report - $Title</h1>"
		$prelim = "<p>$($env:COMPUTERNAME) - $(Get-Date) - $($env:USERNAME)</p>"
		$prelim += "<p>CMHealth version $mversion</p>"
		$footer  = "<p>Copyright &copy;$(Get-Date -f 'yyyy') Skatterbrainz, All rights reserved. No tables reserved.</p>"
		$body = $heading + $prelim + $body + $footer
		$report = "Health Report" | ConvertTo-Html -Title "Health Report" -Body $body -Head $styles
		$report | Out-File $Path -Force
		if ($Show) { Start-Process $Path }
	}
}