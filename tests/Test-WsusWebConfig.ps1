function Test-WsusWebConfig {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Check WSUS Web Config File",
		[parameter()][string] $TestGroup = "configuration",
		[parameter()][string] $Description = "Validate WSUS web configuration file parameters",
		[parameter()][hashtable] $ScriptParams,
		[parameter()][int32] $MaxCachedUpdates = 88000,
		[parameter()][int32] $MaxInstalledPrerequisites = 800,
		[parameter()][ValidateNotNullOrEmpty()][string] $ConfigFile = "C:\Program Files\Update Services\WebServices\ClientWebService\Web.config"
	)
	try {
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat = "PASS"
		if (!(Test-Path $ConfigFile)) {	throw "config file not found: $ConfigFile" }
		# read file contents into XML DOM instance
		[xml]$webconfig = Get-Content $ConfigFile
		# read file contents into text stream instance
		$webconfigraw = Get-Content $ConfigFile

		$c1 = $webconfig.configuration.appSettings.add | Where-Object {$_.key -eq 'maxCachedUpdates'}
		$c2 = $webconfig.configuration.appSettings.add | Where-Object {$_.key -eq 'maxInstalledPrerequisites'}

		if ($c1.value -ne $MaxCachedUpdates) {
			if ($ScriptParams.Remediate -eq $True) {
				$msg = "Updated MaxCachedUpdates $($c1.value) to $MaxCachedUpdates"
				$webconfigraw = $webconfigraw -replace '<add key="maxCachedUpdates" value="22000"/>', '<add key="maxCachedUpdates" value="$MaxCachedUpdates"/>'
				$stat = "REMEDIATED"
			} else {
				$stat = "FAIL"
				$msg  = "MaxCachedUpdates currently $($c1.value) should be $MaxCachedUpdates"
			}
		}

		if ($c2.value -ne $MaxInstalledPrerequisites) {
			if ($ScriptParams.Remediate -eq $True) {
				$msg = "Updated MaxInstalledPrerequisites $($c2.value) to $MaxInstalledPrerequisites"
				$webconfigraw = $webconfigraw -replace '<add key="maxInstalledPrerequisites" value="400"/>', '<add key="maxInstalledPrerequisites" value="$MaxInstalledPrerequisites"/>'
			} else {
				$stat = "FAIL"
				$msg = "MaxInstalledPrerequisites currently $($c2.value) should be $MaxInstalledPrerequisites"
			}
		} 
		
		# more voodoo witchcraft and smoking chickenbones needed here

		# $webconfigraw
		
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
