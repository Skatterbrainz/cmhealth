function Test-HostInstalledSoftware {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Installed Software Applications",
		[parameter()][string] $TestGroup = "configuration",
		[parameter()][string] $TestCategory = "HOST",
		[parameter()][string] $Description = "Check for excessive junk installed on site server",
		[parameter()][hashtable] $ScriptParams
	)
	$startTime = (Get-Date)
	[int]$MaxProducts  = Get-CmHealthDefaultValue -KeySet "siteservers:InstalledSoftwareThreshold" -DataSet $CmHealthConfig
	Write-Log -Message "MaxProducts = $MaxProducts"
	try {
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat   = "PASS" # do not change this
		$except = "WARNING"
		$msg    = "No issues found" # do not change this either
		[array]$res = Get-WmiQueryResult -ClassName "Win32_Product" -Params $ScriptParams | Sort-Object Name
		Write-Log -Message "$($res.Count) products were returned"
		if ($res.Count -gt $MaxProducts) {
			$stat = $except
			$msg  = "$($res.Count) items found. See TestData for item details"
			$res | Foreach-Object {
				$tempdata.Add(
					[pscustomobject]@{
						ProductName = $_.Name
						Version     = $_.Version
						Vendor      = $_.Vendor
						ProductCode = $_.ProductCode
					}
				)
			}
		}
	}
	catch {
		$stat = 'ERROR'
		$msg = $_.Exception.Message -join ';'
	}
	finally {
		if ($cs) { $cs.Close(); $cs = $null }
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
