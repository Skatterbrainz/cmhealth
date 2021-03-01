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
.PARAMETER Show
	Open HTML report when complete
#>

function Out-HealthReport {
	[CmdletBinding()]
	param (
		[parameter(Mandatory=$True, ValueFromPipeline=$True)]$TestData,
		[parameter(Mandatory=$False)][string]$Path = "$($env:USERPROFILE)\Desktop\healthreport.htm",
		[parameter(Mandatory=$False)][string][ValidateSet('All','Fail','Pass','Warning','Error')] $Status = 'All',
		[parameter(Mandatory=$False)][switch]$Show
	)
	$stats = $TestData | Group-Object Status | Select-Object Name,Count,Group

	BEGIN {
		Write-Verbose "defining HTML properties"
		$tablewidth = "800px"
		$leftpanel = "150px"
		$styles = @"
<style>
BODY {background-color:#CCCCCC;font-family:Calibri,sans-serif; font-size: small;}
TABLE {border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse; width: 98%;}
TH {border-width: 1px;padding: 0px;border-style: solid;border-color: black;background-color:#293956;color:white;padding: 5px; font-weight: bold;text-align:left;}
TD {border-width: 1px;padding: 0px;border-style: solid;border-color: black;background-color:#F0F0F0; padding: 2px;}
</style>
"@

		$styles = @"
<style><!--
td,th {font-family:verdana;font-size:10pt;}
body {font-family:calibri,helvetica,sans;}
--></style>
"@
		$heading = "<h1>Health Report</h1>"
		$footer  = "<p>Copyright &copy;$(Get-Date -f 'yyyy') Skatterbrainz, All rights reserved. No tables reserved.</p>"
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
			$chunk = $item | foreach-object {
@"
<h2>$($_.TestName)</h2>
<table width=$tablewidth>
<tr><td width=$leftpanel>Description</td><td>$($_.Description)</td></tr>
<tr><td>Group</td><td>$($_.TestGroup)</td></tr>
<tr><td>Test Result</td><td>$($_.Status)</td></tr>
<tr><td>Message</td><td>$($_.Message)</td></tr>
<tr><td>Runtime</td><td>$($_.Runtime)</td></tr>
"@
				if ($item.TestData.Count -gt 0) {
					$tdata = $item.TestData -join ';'
					$chunk += "<tr><td>Data</td><td>$($tdata.ToString())</td></tr>"
				}
			}
			$chunk += "</table>"
			$body += $chunk
		}
	}
	END {
		Write-Verbose "combining output to HTML"
		$body += $footer

		$statsummary = "<table width=$tablewidth><tr><th>Count</th><th>Result</th><th>Tests</th></tr>"
		$summary | Foreach-Object {
			$statsummary += "<tr><td>$($_.Count)</td><td>$($_.Name)</td><td>$("<ul><li>$($_.Group.TestName -join '</li><li>')</li></ul>")</td></tr>"
		}
		$statsummary += "</table>"

		$body = $heading + $statsummary + $body
		$report = "Health Report" | ConvertTo-Html -Title "Health Report" -Body $body -Head $styles
		$report | Out-File $Path -Force
		if ($Show) { Start-Process $Path }
	}
}