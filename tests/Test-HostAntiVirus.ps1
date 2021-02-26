function Test-HostAntiVirus {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "AntiVirus Product Installations",
		[parameter()][string] $TestGroup = "configuration",
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
		$apps = Get-WmiQueryResult -ClassName "Win32_Product" -Query "Name like '%antivirus%'" -Params $ScriptParams
		$apps | Foreach-Object {
			$tempdata.Add(
				[pscustomobject]@{
					ProductName = $_.Name
					Vendor      = $_.Vendor
					Version     = $_.Version
					DisplayName = $_.Caption
				}
			)
		}
		if ($apps.Count -gt 0) {
			$stat = $except
			$services | Foreach-Object {$tempdata.Add($_.Name)}
			$msg = "Third-party antivirus products were found"
			$services | Foreach-Object {$tempdata.Add($_.Name)}
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
			TestData    = $tempdata
			Description = $Description
			Status      = $stat
			Message     = $msg
			RunTime     = $(Get-RunTime -BaseTime $startTime)
			Credential  = $(if($ScriptParams.Credential){$($ScriptParams.Credential).UserName} else { $env:USERNAME })
		})
	}
}
