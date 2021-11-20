function Test-SqlHostOS {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "SQL Host Operating System",
		[parameter()][string] $TestGroup = "configuration",
		[parameter()][string] $TestCategory = "SQL",
		[parameter()][string] $Description = "Check for supported operating system version",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		$startTime = (Get-Date)
		#[int]$Setting = Get-CmHealthDefaultValue -KeySet "keygroup:keyname" -DataSet $CmHealthConfig
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat   = "PASS" # do not change this
		$except = "WARNING" # or "FAIL"
		$msg    = "No issues found" # do not change this either
		$os = Get-DbaOperatingSystem -ComputerName $ScriptParams.SqlInstance
		if ($os.Version -notin ('9200','9600','10.0.14393','10.0.17763','10.0.18362','10.0.18363','10.0.19041','10.0.20348')) {
			$stat = $except
			$msg = "Possibly unsupported operating system"
		}
		$os | Foreach-Object { 
			$tempdata.Add(
				[pscustomobject]@{
					OSCaption    = $_.OSVersion
					Version      = $_.Version 
					Architecture = $_.Architecture
					LastBootTime = $_.LastBootTime
					TimeZone     = $_.TimeZone
					Language     = $_.LanguageNative
				}
			)
		}
	}
	catch {
		$stat = 'ERROR'
		$msg = $_.Exception.Message -join ';'
	}
	finally {
		Write-Output $([pscustomobject]@{
			TestName    = $TestName
			TestGroup   = $TestGroup
			Category    = $TestCategory
			TestData    = $tempdata
			Description = $Description
			Status      = $stat
			Message     = $msg
			RunTime     = $(Get-RunTime -BaseTime $startTime)
			Credential  = $(if($ScriptParams.Credential){$($ScriptParams.Credential).UserName} else { $env:USERNAME })
		})
	}
}
