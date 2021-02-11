function Test-WsusWebConfig {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Test-WsusWebConfig",
		[parameter()][string] $TestGroup = "configuration",
		[parameter()][string] $Description = "Validate WSUS web configuration file parameters",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		$startTime = (Get-Date)
		[int32] $MaxCachedUpdates = Get-CmHealthDefaultValue -KeySet "wsus:MaxCachedUpdates" -DataSet $CmHealthConfig
		[int32] $MaxInstalledPrerequisites = Get-CmHealthDefaultValue -KeySet "wsus:MaxInstalledPrerequisites" -DataSet $CmHealthConfig
		[string] $ConfigFile = "$($env:PROGRAMFILES)\Update Services\WebServices\ClientWebService\Web.config"

		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat   = "PASS"
		$except = "WARNING"
		$msg    = "No issues found"
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
				$webconfigraw = $webconfigraw -replace "<add key=`"maxCachedUpdates`" value=`"$($c1.value)`"/>", "<add key=`"maxCachedUpdates`" value=`"$MaxCachedUpdates`"/>"
				$stat = "REMEDIATED"
			} else {
				$stat = $except
				$msg  = "MaxCachedUpdates currently $($c1.value) should be $MaxCachedUpdates"
				$tempdata.Add("MaxCachedUpdates=$($c1.Value),Expected=$($MaxCachedUpdates)")
			}
		}

		if ($c2.value -ne $MaxInstalledPrerequisites) {
			if ($ScriptParams.Remediate -eq $True) {
				$msg = "Updated MaxInstalledPrerequisites $($c2.value) to $MaxInstalledPrerequisites"
				$webconfigraw = $webconfigraw -replace "<add key=`"maxInstalledPrerequisites`" value=`"$($c2.value)`"/>", "<add key=`"maxInstalledPrerequisites`" value=`"$MaxInstalledPrerequisites`"/>"
			} else {
				$stat = $except
				$msg = "MaxInstalledPrerequisites currently $($c2.value) should be $MaxInstalledPrerequisites"
				$tempdata.Add("MaxInstalledPrerequisites=$($c2.Value),Expected=$($MaxInstalledPrerequisites)")
			}
		}

		Write-Warning "$TestName - THIS TEST IS NOT YET COMPLETE - PLEASE CONSIDER CONTRIBUTING?"
		# more voodoo witchcraft and smoked chicken bones needed here
		# $webconfigraw

	}
	catch {
		$stat = 'ERROR'
		$msg = $_.Exception.Message -join ';'
	}
	finally {
		$rt = Get-RunTime -BaseTime $startTime
		Write-Output $([pscustomobject]@{
			TestName    = $TestName
			TestGroup   = $TestGroup
			TestData    = $tempdata
			Description = $Description
			Status      = $stat
			Message     = $msg
			RunTime     = $rt
			Credential  = $(if($ScriptParams.Credential){$($ScriptParams.Credential).UserName} else { $env:USERNAME })
		})
	}
}
