function Test-CmClientBoundaryExceptions {
	[CmdletBinding()]
	[OutputType()]
	param (
		[parameter()][string] $TestName = "Check client boundary groups",
		[parameter()][string] $TestGroup = "operation",
		[parameter()][string] $TestCategory = "CM",
		[parameter()][string] $Description = "Check for Clients not in a boundary group",
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
cdr.Name, CASE WHEN (BoundaryGroups IS NULL) THEN 'NONE' 
ELSE BoundaryGroups END AS BoundaryGroups, 
cdr.ADSiteName, cdr.DeviceOS, cdr.DeviceOSBuild, cdr.LastMPServerName, 
cdr.SerialNumber, cdr.MACAddress, cdr.LastLogonUser, cs.Model0 AS Model, cs.Manufacturer0 AS Manufacturer
FROM v_CombinedDeviceResources AS cdr INNER JOIN
v_GS_COMPUTER_SYSTEM AS cs ON cdr.MachineID = cs.ResourceID
WHERE (cdr.Name NOT IN ('x86 Unknown Computer (x86 Unknown Computer)', 'x64 Unknown Computer (x64 Unknown Computer)', 'Provisioning Device (Provisioning Device)'))
ORDER BY cdr.Name"
		$res = Get-CmSqlQueryResult -Query $query -Params $ScriptParams
		$set2 = $res | Where-Object {$_.BoundaryGroups -eq 'NONE'}
		if ($set2.Count -gt 0) {
			$stat = $except
			$msg  = "$($set2.Count) clients found without an assigned boundary group"
			Write-Log -Message $msg -Category Warning
			$set2 | Foreach-Object {
				$tempdata.Add(
					[pscustomobject]@{
						Name         = $_.Name
						OS           = "$($_.DeviceOS) $($_.DeviceOSBuild)"
						Manufacturer = $_.Manufacturer
						Model        = $_.Model
						ADSite       = $_.ADSiteName
						SerialNumber = $_.SerialNumber
						MACAddress   = $_.MACAddress
						LastUser     = $_.LastLogonUser
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
		Set-CmhOutputData
	}
}
