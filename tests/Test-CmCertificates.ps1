function Test-CmCertificates {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Site Certificate Expirations",
		[parameter()][string] $TestGroup = "operation",
		[parameter()][string] $Description = "Check certificate expiration dates",
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
		Write-Verbose "submitting query"
		$res = Get-CmSqlQueryResult -Query $query -Params $ScriptParams
		Write-Verbose "returned $($res.Count) items"
		foreach ($row in $res) {
			[string]$cfg = $($row.Configuration -replace "`n",",")
			[datetime]$exp = $($cfg -split 'Expires:')[1].Trim()
			Write-Verbose "expiration date is $exp"
			if ((New-TimeSpan -Start (Get-Date) -End $exp).Days -lt 30) {
				Write-Verbose "expiration less than 30 days"
				$stat = $except
				$msgx = "Certificate about to expire or has expired"
			} else {
				$msgx = "Valid"
			}
			$tempdata.Add(
				[pscustomobject]@{
					RoleName = $row.RoleName
					Details  = $msgx
					Configuration = $row.Configuration
					Expiration = $exp
				}
			)
		}
		if ($res.Count -gt 0) {
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
