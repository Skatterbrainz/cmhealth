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
			$trun   = $item.RunTime
			$tdata  = $item.TestData | ConvertTo-Html -Fragment
			$chunk  = $item | foreach-object {
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
			}
			$body += $chunk
		} # foreach
	}
	END {
		$stats = $inputData | Group-Object Status | Select-Object Name,Count,Group
		$styles = @"
<style>
BODY {background-color:#CCCCCC;font-family:Calibri,sans-serif; font-size: small;}
TABLE {border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse; width: 98%;}
TH {border-width: 1px;padding: 0px;border-style: solid;border-color: black;background-color:#293956;color:white;padding: 5px; font-weight: bold;text-align:left;}
TD {border-width: 1px;padding: 0px;border-style: solid;border-color: black;background-color:#F0F0F0; padding: 2px;}
</style>
"@
		Write-Verbose "combining output to HTML"

		#$statsummary = "<table width=$tablewidth><tr><th>Count</th><th>Result</th><th>Tests</th></tr>"
		#$stats | Foreach-Object {
		#	$statsummary += "<tr><td>$($_.Count)</td><td>$($_.Name)</td><td>$("<ul><li>$($_.Group.TestName -join '</li><li>')</li></ul>")</td></tr>"
		#}
		#$statsummary += "</table>"

		$heading = "<h1>Health Report</h1>"
		$footer  = "<p>Copyright &copy;$(Get-Date -f 'yyyy') Skatterbrainz, All rights reserved. No tables reserved.</p>"
		#$body = $heading + $statsummary + $body + $footer
		$body = $heading + $body + $footer
		$report = "Health Report" | ConvertTo-Html -Title "Health Report" -Body $body -Head $styles
		$report | Out-File $Path -Force
		if ($Show) { Start-Process $Path }
	}
}