function Test-CmUpdateCompliance {
	[CmdletBinding()]
	[OutputType()]
	param (
		[parameter()][string] $TestName = "Software Update Compliance Summary",
		[parameter()][string] $TestGroup = "operation",
		[parameter()][string] $TestCategory = "CM",
		[parameter()][string] $Description = "Summary of required updates not yet installed",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		$startTime = (Get-Date)
		#[int]$Setting = Get-CmHealthDefaultValue -KeySet "keygroup:keyname" -DataSet $CmHealthConfig
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat   = "PASS" # do not change this
		$except = "WARNING"
		$msg    = "No issues found" # do not change this either
		$query = @"
SELECT
	vRS.Netbios_Name0 AS 'DeviceName',
	vSN_Status.StateDescription,
	vCCI.CategoryInstanceName AS 'UpdateClassification',
	vUI.Title,
	vUI.Description,
	vUI.InfoURL,
	vUI.ArticleID,
	vUI.BulletinID,
    vUI.MaxExecutionTime,
	vUCS.LastStatusChangeTime,
	vUCS.LastErrorCode
FROM
	dbo.v_Update_ComplianceStatus AS vUCS LEFT OUTER JOIN
    dbo.v_UpdateInfo AS vUI ON vUCS.CI_ID = vUI.CI_ID LEFT OUTER JOIN
    dbo.v_R_System AS vRS ON vUCS.ResourceID = vRS.ResourceID LEFT OUTER JOIN
    dbo.v_StateNames AS vSN_Status ON vUCS.Status = vSN_Status.StateID LEFT OUTER JOIN
    dbo.v_CICategoryInfo AS vCCI ON vCCI.CI_ID = vUCS.CI_ID
WHERE
	(LTRIM(vRS.Netbios_Name0) <> '') AND
	(vCCI.CategoryTypeName = 'UpdateClassification') AND
	(vSN_Status.TopicType = 500) AND
	(vUI.CIType_ID = 8) AND
	(vUI.IsSuperseded = 0) AND
	(vCCI.CategoryInstanceName IN ('Security Updates', 'Critical Updats')) AND
    (vSN_Status.StateDescription = 'Update is required')
ORDER BY
	'DeviceName', vUI.Title
"@
		$res = Get-CmSqlQueryResult -Query $query -Params $ScriptParams
		if ($res.Count -gt 0) {
			$stat = $except
			$msg  = "$($res.Count) items found"
			$res | Foreach-Object {
				$dataset = [pscustomobject]@{
					DeviceName = $($_.DeviceName)
					UpdateClassification = $($_.UpdateClassification)
					State = $($_.StateDescription)
					Article = $($_.ArticleID)
					Title = $($_.Title)
					LastError = $($_.LastErrorCode)
				}
				$tempdata.Add($dataset)
			}
		} else {
			Write-Log -Message "no issues found"
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
