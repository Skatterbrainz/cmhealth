<#
.SYNOPSIS
	Verify WSUS web.config settings
.DESCRIPTION
	Verify WSUS web.config settings are related to number of updates
.PARAMETER MaxCachedUpdates
	Maximum number of cached updates (default is 88000)
	fyi - Built-in default is 22000
.PARAMETER MaxInstalledPrerequisites
	Maximum number of installed prerequisites (default is 800)
	fy - Built-in default is 400
.PARAMETER ConfigFile
	Path to WSUS web.config file
.PARAMETER Remediate
	Apply remediation changes if needed
.NOTES
	1. get number of updates in database
	2. compare with settings in web.config
#>
function Test-Example {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Descriptive Name",
		[parameter()][string] $TestGroup = "configuration",
		[parameter()][string] $Description = "Description of this test",
		[parameter()][bool] $Remediate = $False,
		[parameter()][string] $ComputerName = "localhost",
		[parameter()][int32] $MaxCachedUpdates = 88000,
		[parameter()][int32] $MaxInstalledPrerequisites = 800,
		[parameter()][ValidateNotNullOrEmpty()][string] $ConfigFile = "C:\Program Files\Update Services\WebServices\ClientWebService\Web.config"
	)
	try {
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat = "PASS"
		if (!(Test-Path $ConfigFile)) {
			throw "config file not found: $ConfigFile"
		}
		# read file contents into XML DOM instance
		[xml]$webconfig = Get-Content $ConfigFile
		# read file contents into text stream instance
		$webconfigraw = Get-Content $ConfigFile

		$c1 = $webconfig.configuration.appSettings.add | Where-Object {$_.key -eq 'maxCachedUpdates'}
		$c2 = $webconfig.configuration.appSettings.add | Where-Object {$_.key -eq 'maxInstalledPrerequisites'}

		if ($c1.value -ne $MaxCachedUpdates) {
			if ($Remediate -eq $True) {
				$msg = "Updated $($c1.value) to $MaxCachedUpdates"
				$webconfigraw = $webconfigraw -replace '<add key="maxCachedUpdates" value="22000"/>', '<add key="maxCachedUpdates" value="$MaxCachedUpdates"/>'
				$stat = "REMEDIATED"
			} else {
				$stat = "FAIL"
				$msg  = "Updated $($c1.value) should be $MaxCachedUpdates"
			}
		}

		if ($c2.value -ne $MaxInstalledPrerequisites) {
			if ($Remediate -eq $True) {
				$msg = "Updated $($c2.value) to $MaxInstalledPrerequisites"
				$webconfigraw = $webconfigraw -replace '<add key="maxInstalledPrerequisites" value="400"/>', '<add key="maxInstalledPrerequisites" value="$MaxInstalledPrerequisites"/>'
			} else {
				$stat = "FAIL"
				$msg = "Updated $($c2.value) should be $MaxInstalledPrerequisites"
			}
		} 
		#$webconfigraw
		
	}
	catch {
		$stat = 'ERROR'
		$msg = $_.Exception.Message -join ';'
	}
	finally {
		Write-Output $([pscustomobject]@{
			TestName    = $TestName
			TestGroup   = $TestGroup
			TestData    = $tempdata
			Description = $Description
			Status      = $stat 
			Message     = $msg
		})
	}
}
