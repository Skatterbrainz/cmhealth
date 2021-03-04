function Test-CmContentMissing {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Packages Missing Content",
		[parameter()][string] $TestGroup = "operation",
		[parameter()][string] $Description = "Check for items missing content for distribution",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		$startTime = (Get-Date)
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat   = "PASS"
		$except = "WARNING"
		$msg    = "No issues found"
		$query = "SELECT
SourceSite,
SoftwareName,
Targeted,
NumberInstalled,
NumberErrors,
NumberInProgress,
NumberUnknown,
CASE ObjectType
	WHEN 0 THEN 'Package'
	WHEN 3 THEN 'Driver Package'
	WHEN 5 THEN 'Software Update Package'
	WHEN 257 THEN 'Operating System Image'
	WHEN 258 THEN 'Boot Image'
	WHEN 259 THEN 'Operating System Installer'
	WHEN 512 THEN 'Application'
	ELSE 'Unknown ID ' +  CONVERT(VARCHAR(200), ObjectType)
END AS ObjectTypeName
FROM fn_ListObjectContentExtraInfo(1033) AS SMS_ObjectContentExtraInfo
WHERE Targeted > 0 AND NumberInstalled <> Targeted"
		$res = Get-CmSqlQueryResult -Query $query -Params $ScriptParams
		if ($null -ne $res -and $res.Count -gt 0) {
			$stat = $except
			$msg  = "$($res.Count) items missing content: $($res.SoftwareName -join ',')"
			$res | Foreach-Object {
				$tempdata.Add(
					[pscustomobject]@{
						Name = $($_.SoftwareName)
						Type = $($_.ObjectTypeName)
						Errors = $($_.NumberErrors)
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
