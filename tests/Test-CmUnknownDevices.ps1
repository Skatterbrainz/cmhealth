function Test-CmUnknownDevices {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Check for Unknown Devices",
		[parameter()][string] $TestGroup = "operation",
		[parameter()][string] $TestCategory = "CM",
		[parameter()][string] $Description = "Devices named UNKNOWN* or MININT* left from failed imaging events",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		$startTime = (Get-Date)
		#[int]$Setting = Get-CmHealthDefaultValue -KeySet "keygroup:keyname" -DataSet $CmHealthConfig
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat   = "PASS" # do not change this
		$except = "WARNING" # or "FAIL"
		$msg    = "No issues found" # do not change this either
		$query = "SELECT sys.Name0, sys.ResourceID, cdr.SMSID, cdr.MACAddress, cdr.SerialNumber
FROM dbo.v_R_System AS sys LEFT OUTER JOIN
dbo.v_CombinedDeviceResources AS cdr ON sys.ResourceID = cdr.MachineID
WHERE (sys.Name0 LIKE '%Unknown%') OR (sys.Name0 LIKE 'MININT%')
ORDER BY sys.Name0"
		$res = Get-CmSqlQueryResult -Query $query -Params $ScriptParams
		if ($res.Count -gt 0) {
			$stat = $except
			$msg  = "$($res.Count) items returned"
			$res | Foreach-Object {
				$tempdata.Add(
					[pscustomobject]@{
						Name = $_.Name0
						SMSID = $_.SMSID
						MAC = $_.MACAddress
						SerialNumber = $_.SerialNumber
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
