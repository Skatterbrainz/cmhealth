function Test-HostAntiVirus {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "AntiVirus Product Installations",
		[parameter()][string] $TestGroup = "configuration",
		[parameter()][string] $TestCategory = "HOST",
		[parameter()][string] $Description = "Check for third-party antivirus software installations",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		$startTime = (Get-Date)
		#[int]$Setting = Get-CmHealthDefaultValue -KeySet "keygroup:keyname" -DataSet $CmHealthConfig
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat   = "PASS" # do not change this
		$except = "WARNING"
		$msg    = "No issues found" # do not change this either
		$apps = Get-WmiQueryResult -ClassName "Win32_Product" -Query "" -Params $ScriptParams
		$apps | Foreach-Object {
			$appname = $_.Name
			foreach ($pn in ('McAfee','Sophos','Symantec','antivirus','malware','security','endpoint')) {
				if ($appname -match $pn) {
					Write-Log -Message "match found: $appname"
					$tempdata.Add(
						[pscustomobject]@{
							ProductName = $_.Name
							Vendor      = $_.Vendor
							Version     = $_.Version
							DisplayName = $_.Caption
						}
					)
				}
			} # foreach
		}
	}
	catch {
		$stat = 'ERROR'
		$msg = $_.Exception.Message -join ';'
	}
	finally {
		$([pscustomobject]@{
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
