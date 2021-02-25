function Test-CmSiteAdminsCount {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Site Admins Membership Count",
		[parameter()][string] $TestGroup = "configuration",
		[parameter()][string] $Description = "Check if more users are full admins than should be",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		$startTime = (Get-Date)
		[int]$defaultSetting = Get-CmHealthDefaultValue -KeySet "configmgr:MaxAdministratorsCount" -DataSet $CmHealthConfig
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat   = "PASS" # do not change this
		$except = "WARNING" # or "FAIL"
		$msg    = "No issues found" # do not change this either
		$query = "select LogonName,DisplayName,IsGroup,AdminSID from v_Admins"
		[array]$res = Get-CmSqlQueryResult -Query $query -Params $ScriptParams
		if ($res.Count -gt $defaultSetting) {
			$stat = $except
			$msg  = "$($res.Count) items found"
			$res | Foreach-Object {
				$tempdata.Add(
					[pscustomobject]@{
						LogonName = $_.LogonName
						DisplayName = $_.Displayname
						IsGroup = $_.IsGroup
						SID = $_.AdminSID
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
