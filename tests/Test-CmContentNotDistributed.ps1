function Test-CmContentNotDistributed {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Test-CmContentNotDistributed",
		[parameter()][string] $TestGroup = "operation",
		[parameter()][string] $Description = "Check for content not distributed",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat = "PASS"
		$msg  = "No issues found"
		$query = "SELECT
SourceSite,
SoftwareName,
CASE ObjectType
	WHEN 0 THEN 'Package'
	WHEN 3 THEN 'Driver Package'
	WHEN 5 THEN 'Software Update Package'
	WHEN 257 THEN 'Operating System Image'
	WHEN 258 THEN 'Boot Image'
	WHEN 259 THEN 'Operating System Installer'
	WHEN 512 THEN 'Application'
	ELSE 'Unknown ID ' +  CONVERT(VARCHAR(200), ObjectType)
END AS ObjectTYpeName
FROM fn_ListObjectContentExtraInfo(1033) AS SMS_ObjectContentExtraInfo
WHERE Targeted = 0"
		$res = @(Invoke-DbaQuery -SqlInstance $ScriptParams.SqlInstance -Database $ScriptParams.Database -Query $query)
		if ($res.Count -gt 1) {
			$stat = "WARNING"
			$msg = "$($res.Count) packages with content are not distributed"
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
			Credential  = $(if($ScriptParams.Credential){$($ScriptParams.Credential).UserName} else { $env:USERNAME })
		})
	}
}
