function Test-CmBootImages {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Verify Boot Image OS Versions",
		[parameter()][string] $TestGroup = "configuration",
		[parameter()][string] $Description = "Check if Boot Images are supported OS versions",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		$startTime = (Get-Date)
		#[int]$Setting = Get-CmHealthDefaultValue -KeySet "keygroup:keyname" -DataSet $CmHealthConfig
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat   = "PASS" # do not change this
		$except = "WARNING" # or "FAIL"
		$msg    = "No issues found" # do not change this either
		$query = "SELECT DISTINCT
bip.PackageID, bip.Name, bip.Version, 
CASE 
WHEN (LEFT(Version, 10) = '10.0.10240') THEN '1507' 
WHEN (LEFT(Version, 10) = '10.0.10586') THEN '1511' 
WHEN (LEFT(Version, 10) = '10.0.14393') THEN '1607' 
WHEN (LEFT(Version, 10) = '10.0.15063') THEN '1703' 
WHEN (LEFT(Version, 10) = '10.0.16299') THEN '1709' 
WHEN (LEFT(Version, 10) = '10.0.17134') THEN '1803' 
WHEN (LEFT(Version, 10) = '10.0.17763') THEN '1809' 
WHEN (LEFT(Version, 10) = '10.0.18362') THEN '1903' 
WHEN (LEFT(Version, 10) = '10.0.18363') THEN '1909' 
WHEN (LEFT(Version, 10) = '10.0.19041') THEN '2004' 
WHEN (LEFT(Version, 10) = '10.0.19042') THEN '20H2' 
WHEN (LEFT(Version, 10) = '10.0.19043') THEN '21H1' 
WHEN (LEFT(Version, 10) = '10.0.19044') THEN '21H2' 
WHEN (LEFT(Version, 10) = '10.0.22000') THEN '21H1' 
ELSE '' END AS BuildNumber, 
bip.Description, 
bip.PkgSourcePath, 
bip.SourceDate, 
bip.LastRefreshTime, 
CASE WHEN (DPNALPath LIKE '%cloudapp.net%') then 'Cloud DP' 
else 'OnPrem DP' end as DPType
FROM            
dbo.v_BootImagePackage as bip LEFT OUTER JOIN
dbo.v_DistributionStatus AS ds ON bip.PackageID = ds.PkgID"
		[array]$res = Get-CmSqlQueryResult -Query $query -Params $ScriptParams
		if ($res.Count -gt 0) {
			$msg  = "$($res.Count) items found"
			[array]$cdp  = $res | Where-Object {$_.DPType -eq 'Cloud DP'}
			if ($cdp.Count -gt 0) {
				$stat = $except
				$msg = "Content distributed to $($cdp.Count) cloud distribution points"
			}
			$res | Foreach-Object {
				$tempdata.Add(
					[pscustomobject]@{
						Name        = $_.Name
						PackageID   = $_.PackageID
						Version     = $_.Version
						BuildNumber = $_.BuildNumber
						Description = $_.Description
						SourcePath  = $_.PkgSourcePath
						DPType      = $_.DPType
					}
				)
			}
		} else {
			$msg = "No boot images found"
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
