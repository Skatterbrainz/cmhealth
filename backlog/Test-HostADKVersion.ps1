function Test-HostADKVersion {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Validate ADK Version",
		[parameter()][string] $TestGroup = "configuration",
		[parameter()][string] $TestCategory = "CM",
		[parameter()][string] $Description = "Verify ADK version is supported",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		$startTime = (Get-Date)
		# https://docs.microsoft.com/en-us/mem/configmgr/core/plan-design/configs/support-for-windows-10
		$adk_cm = [pscustomobject]@{
			"10.1.17763" = ("1906","1910")
			"10.1.18362" = ("1906","1910","2002","2006","2010")
			"10.1.19041" = ("2002","2006","2010")
		}
		$w10_cm = [pscustomobject]@{
			"10.0.17134" = ("1906","1910","2002","2006","2010")
			"10.0.17763" = ("1906","1910","2002","2006","2010")
			"10.0.18363" = ("1906","1910","2002","2006","2010")
			"10.0.19041" = ("2002","2006","2010")
			"10.0.19042" = ("2006","2010")
		}
		#[int]$Setting = Get-CmHealthDefaultValue -KeySet "keygroup:keyname" -DataSet $CmHealthConfig
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat   = "PASS" # do not change this
		$except = "WARNING" # or "FAIL"
		$msg    = "No issues found" # do not change this either
		$apps = Get-WmiQueryResult -ClassName "Win32_Product" -Query "Name = 'Windows PE x86 x64'" -Params $ScriptParams
		foreach ($app in $apps) {
			$name = $app.Name
			$version = $app.Version
			# to-do: get cm site version and compare against $versionTable
			[string]$cmsiteversion = $(Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\SMS\Setup' -Name "Version")."Version"
			$versionName = Get-CmVersionName -Version $cmsiteversion
			$tempdata.Add(
				[pscustomobject]@{
					ADKPE   = $name
					Version = $version
					Build   = $versionName
				}
			)
		} # foreach
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
			RunTime     = $(Get-RunTime -BaseTime $startTime)
			Credential  = $(if($ScriptParams.Credential){$($ScriptParams.Credential).UserName} else { $env:USERNAME })
		})
	}
}
