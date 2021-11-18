function Test-CmSiteCertificates {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Site Certificate Expirations",
		[parameter()][string] $TestGroup = "operation",
		[parameter()][string] $TestCategory = "CM",
		[parameter()][string] $Description = "Check certificate expiration dates",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		$startTime = (Get-Date)
		#[int]$Setting = Get-CmHealthDefaultValue -KeySet "keygroup:keyname" -DataSet $CmHealthConfig
		[int]$expdays = 30
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat   = "PASS" # do not change this
		$except = "WARNING" # or "FAIL"
		$msg    = "No issues found" # do not change this either
		$query = "SELECT SiteCode,RoleID,RoleName,State,Configuration,MessageID,LastEvaluatingTime,Param1
FROM dbo.vCM_SiteConfiguration where RoleName like '%Certificate'"
		Write-Log -Message "submitting query"
		$res = Get-CmSqlQueryResult -Query $query -Params $ScriptParams
		Write-Log -Message "returned $($res.Count) certificate records"
		$ecount = 0
		foreach ($row in $res) {
			[string]$cfg = $($row.Configuration -replace "`n",",")
			[datetime]$exp = $($cfg -split 'Expires:')[1].Trim()
			Write-Log -Message "expiration date is $exp"
			if ((New-TimeSpan -Start (Get-Date) -End $exp).Days -lt $expdays) {
				Write-Verbose "expiration less than $expdays days"
				$stat = $except
				$msgx = "Certificate about to expire or has expired"
				$ecount++
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
		if ($ecount -gt 0) {
			$stat = $except
			$msg  = "$($ecount) of $($res.Count) certificates expired or will expire within $expdays days"
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
