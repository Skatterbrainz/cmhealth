function Test-CmCertificates {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Site Certificates",
		[parameter()][string] $TestGroup = "operation",
		[parameter()][string] $Description = "Check for certificate expirations",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		$startTime = (Get-Date)
		#[int]$Setting = Get-CmHealthDefaultValue -KeySet "keygroup:keyname" -DataSet $CmHealthConfig
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat   = "PASS" # do not change this
		$except = "WARNING" # or "FAIL"
		$msg    = "No issues found" # do not change this either
		$query = "SELECT SiteCode,RoleID,RoleName,State,Configuration,MessageID,LastEvaluatingTime,Param1
  			FROM dbo.vCM_SiteConfiguration where RoleName like '%Certificate'"
		$res = Get-CmSqlQueryResult -Query $query -Params $ScriptParams
		foreach ($row in $res) {
			[datetime]$exp = $(($row -split 'Expires:')[1]).Trim()
			if ((New-TimeSpan -Start (Get-Date) -End $exp).Days -lt 30) {
				$stat = $except
				$msg = "Certificate about to expire or has expired"
				$tempdata.Add(
					[pscustomobject]@{
						RoleName = $row.RoleName
						Details = $msg
						Configuration = $row.Configuration
						Expiration = (Get-Date $exp -f 'MM/dd/yyyy')
					}
				)
			}
		}
		if ($null -ne $res -and $res.Count -gt 0) {
			$stat = $except
			$msg  = "$($res.Count) items found"
			#$res | Foreach-Object {$tempdata.Add( [pscustomobject]@{Name=$_.Name} )}
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
