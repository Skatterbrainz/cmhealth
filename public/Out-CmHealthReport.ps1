<#
.SYNOPSIS
	Export CMHealth test results to HTML files
.DESCRIPTION
	Export CMHealth test results to HTML files.  If -Detailed is invoked, each test is output
	to a separate file with a parent table-of-contents (index) file providing links to each.
	If -Detailed is not used, all of the tests are output to a single HTML file.
.PARAMETER InputObject
	Required. The output from from Test-CmHealth
.PARAMETER Detailed
	Optional. Produces verbose report files with TestData included.
.PARAMETER Title
	Optional. Title for report heading. Default is "CMHealth Test Results"
.PARAMETER CssFile
	Optional. Path to custom CSS stylesheet file. If not provided, internal CSS is used by default.
.PARAMETER Show
	Optional. Open HTML report when complete
.PARAMETER OutputFolder
	Optional. Path where log file and report files are created. Default is $env:TEMP
.EXAMPLE
	$testresult = Test-CmHealth -SiteCode P01 -Database CM_P01
	$testresult | Out-CmHealthReport -Show
	Create summary report and open in browser when finished
.EXAMPLE
	Test-CmHealth -SiteCode P01 -Database CM_P01 | Where-Object {$_.Status -eq 'FAIL'} | Out-CmHealthReport -Show
	Create reports for failed tests only, then open in browser when finished
.EXAMPLE
	$testresult = Test-CmHealth -SiteCode P01 -Database CM_P01
	$testresult | Out-CmHealthReport -Detailed -Title "Contoso Health Report" -Show
.EXAMPLE
	$testresult = Test-CmHealth -SiteCode P01 -Database CM_P01
	$testresult | Out-CmHealthReport -Detailed -Title "Contoso Health Report" -CssFile "c:\stylesheet.css" -Footer "Contoso Corp"
.LINK
	https://github.com/Skatterbrainz/cmhealth/blob/master/docs/Out-CmHealthReport.md
.NOTES
	Thank you!
#>

function Out-CmHealthReport {
	[CmdletBinding()]
	param (
		[parameter(Mandatory=$True,ValueFromPipeline=$True)]$InputObject,
		[parameter(Mandatory=$False)][switch]$Detailed,
		[parameter(Mandatory=$False)][string]$Title = "CMHealth Test Results",
		[parameter(Mandatory=$False)][string]$CssFile = "",
		[parameter(Mandatory=$False)][string]$OutputFolder = "$($env:TEMP)",
		[parameter(Mandatory=$False)][switch]$Show,
		[parameter(Mandatory=$False)][string]$Footer = ""
	)
	BEGIN {
		$LogFile = Join-Path -Path $OutputFolder -ChildPath "cmhealth_$(Get-Date -f 'yyyy-MM-dd').log"
		Write-Log -Message "getting module information"
		$mversion = (Get-Module cmhealth -ListAvailable | Select-Object -First 1).Version -join '.'
		if ($null -ne $GLOBAL:CmhParams) {
			Write-Log -Message "appending site code to report title"
			$Title += " $(($GLOBAL:CmhParams).SiteCode)"
		}
		if ([string]::IsNullOrEmpty($CssFile)) {
			Write-Log -Message "setting internal default CSS style table"
			$styles = @"
<style>
BODY {background-color:#CCCCCC;font-family:Calibri,sans-serif; font-size: small;}
TABLE {border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse; width: 98%;}
TH {border-width: 1px;padding: 0px;border-style: solid;border-color: black;background-color:#293956;color:white;padding: 5px; font-weight: bold;text-align:left;font-size:10pt;}
TD {border-width: 1px;padding: 0px;border-style: solid;border-color: black;background-color:#F0F0F0; padding: 2px;font-size:10pt;}
</style>
"@
		} else {
			Write-Log -Message "applying CSS from file: $CssFile"
			if (Test-Path $CssFile) {
				Write-Log -Message "reading CSS style data from file"
				$cssdata = Get-Content -Path $CssFile
				$styles = "<style>$cssdata</style>"
			}
		}
		Write-Log -Message "setting HTML outer content: section1"
		$section1 = "<html>
		<head>
		<title>$Title</title>
		$styles
		</head>
		<body>
		<h1>CMHealth Test Results - $Title</h1>
		<p>Run date: $(Get-Date). Version: cmhealth version $($mversion). Runon: $($env:COMPUTERNAME). RunAs: $($env:USERNAME)</p>"
		Write-Log -Message "setting HTML outer content: section2"
		if (![string]::IsNullOrEmpty($Footer)) {
			$section2 = "<p>$Footer</p></body></html>"
		} else {
			$section2 = "<p>Please support CMHealth - visit <a href=`"https://github.com/skatterbrainz/cmhealth`">https://github.com/skatterbrainz/cmhealth</a> - Thank you!</p></body></html>"
		}
		if ($Detailed) {
			Write-Log -Message "preparing table of contents"
			$toc = "<table>
			<tr>
			<th style=`"width:100px`">Category</th>
			<th style=`"width:150px`">Group</th>
			<th style=`"width:150px`">Result</th>
			<th>Test Name</th></tr>"
			$content = $section1
		} else {
			$content = $section1
		}
	}
	PROCESS {
		if ($Detailed) {
			Write-Log -Message "appending test-block: $($_.TestName)"
			if ($null -eq $_.TestData) {
				$testdata = "(no test data returned)"
			} else {
				Write-Log -Message "expanding test results data"
				$testdata = $($_.TestData | ConvertTo-Html -Fragment)
			}
			$chunk = "<h3>$($_.TestName)</h3>
			<table>
			<tr><th style=`"width:200px`">Description</th><td>$($_.Description)</td></tr>
			<tr><th style=`"width:200px`">Category</th><td>$($_.Category)</td></tr>
			<tr><th style=`"width:200px`">Group</th><td>$($_.TestGroup)</td></tr>
			<tr><th style=`"width:200px`">Test Result</th><td>$($_.Status)</td></tr>
			<tr><th style=`"width:200px`">Message</th><td>$($_.Message)</td></tr>
			<tr><th style=`"width:200px`">Runtime</th><td>$($_.RunTime)</td></tr>
			<tr><th style=`"width:200px`">Details</th><td>$testdata</td></tr>
			</table>"
			$content = $($section1 + $chunk + $section2)
			$fname = "cmhealth-$($($GLOBAL:CmhParams).SiteCode)-$($_.Category)-$($_.Status)-$($_.TestName -replace ' ','-')-$(Get-Date -f 'yyyyMMdd').htm"
			$ReportFile = Join-Path -Path $OutputFolder -ChildPath $fname
			Write-Log -Message "writing file: $ReportFile"
			$content | Out-File -FilePath $ReportFile -Encoding UTF8 -Force
			Write-Log -Message "appending table of contents"
			$toc += "<tr><td>$($_.Category)</td><td>$($_.TestGroup)</td><td>$($_.Status)</td>
			<td><a href=`"$ReportFile`" title=`"View Test Results`">$($_.TestName)</a></td></tr>"
		} else {
			#$content = $section1
			switch ($_.Status) {
				'PASS' { $tstat = "<span style=color:green>$tstat</span>"}
				'FAIL' { $tstat = "<span style=color:red>$tstat</span>"}
				'WARNING' { $tstat = "<span style=color:orange>$tstat</span>"}
				default { $tstat = "<span style=color:red>$tstat</span>"}
			}
			Write-Log -Message "appending test-block: $($_.TestName)"
			$chunk = "<h3>$($_.TestName)</h3>
			<table>
			<tr><th style=`"width:200px`">Description</th><td>$($_.Description)</td></tr>
			<tr><th style=`"width:200px`">Category</th><td>$($_.Category)</td></tr>
			<tr><th style=`"width:200px`">Group</th><td>$($_.TestGroup)</td></tr>
			<tr><th style=`"width:200px`">Test Result</th><td>$tstat</td></tr>
			<tr><th style=`"width:200px`">Message</th><td>$($_.Message)</td></tr>
			<tr><th style=`"width:200px`">Runtime</th><td>$($_.RunTime)</td></tr>
			</table>"
			$content += $chunk
		}
	}
	END {
		if (!$Detailed) {
			$ReportFile = Join-Path -Path $OutputFolder -ChildPath "cmhealth-summary-$($($GLOBAL:CmhParams).SiteCode)-$(Get-Date -f 'yyyyMMdd').htm"
			Write-Log -Message "writing file: $ReportFile"
			$content += $section2 
			$content | Out-File -FilePath $ReportFile -Encoding UTF8 -Force
			if ($Show) { 
				Start-Process $ReportFile 
			} else {
				Write-Host "Report written to: $ReportFile"
			}
		} else {
			Write-Log -Message "closing table of contents"
			$toc += "</table>"
			$IndexFile = Join-Path -Path $OutputFolder -ChildPath "cmhealth-index-$($($GLOBAL:CmhParams).SiteCode)-$(Get-Date -f 'yyyyMMdd').htm"
			Write-Log -Message "writing file: $IndexFile"
			$content = "<html>
			<head>
			<title>$Title</title>
			$styles
			</head>
			<body>
			<h1>CMHealth Test Results - $Title</h1>
			<p>Run date: $(Get-Date)</p>
			<p>Version: cmhealth version $($mversion). Runon: $($env:COMPUTERNAME). RunAs: $($env:USERNAME)</p>
			$toc
			</body></html>"
			$content | Out-File -FilePath $IndexFile -Encoding UTF8 -Force
			if ($Show) { 
				Start-Process $IndexFile 
			} else {
				Write-Host "Report written to $IndexFile"
			}
		}
	}
}