function Test-CmUpdateCompliance {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Test-CmUpdateCompliance",
		[parameter()][string] $TestGroup = "operation",
		[parameter()][string] $Description = "Summary of required updates not yet installed",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		#[int]$Setting = Get-CmHealthDefaultValue -KeySet "keygroup:keyname" -DataSet $CmHealthConfig
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat = "PASS" # do not change this
		$msg  = "No issues found" # do not change this either
		$query = "select 
	vRS.NetBIOS_Name0 as 'DeviceName',
	vSN_Status.StateDescription,
	vCCI.CategoryInstanceName as 'UpdateClassification',
	vUI.Title,
	vUI.Description,
	vUI.InfoURL,
	vUI.ArticleID,
	vUI.BulletinID,
	vUI.MaxExecutionTime,
	vUCS.LastStatusChangeTime,
	vUCS.LastErrorCode 
from
	dbo.v_Update_ComplianceStatus as vUCS​
	Left Join dbo.v_UpdateInfo as vUI​ on vUCS.CI_ID = vUI.CI_ID​
	Left Join dbo.v_R_System as vRS​ on vUCS.ResourceID = vRS.ResourceID​
	Left Join dbo.v_StateNames as vSN_Status​ on vSN_Status.TopicType = 500 ​and vSN_Status.StateID = vUCS.Status​
	Left Join v_CICategoryInfo as vCCI​ on vCCI.CategoryTypeName='UpdateClassification'​ and vUCS.CI_ID = vCCI.CI_ID​
Where ​
	(vUI.CIType_ID = 8)
	and
	(vUI.IsSuperseded = 0)
	and 
	(vCCI.CategoryInstanceName in ('Security Updates','Critical Updates'))
	and
	(vSN_Status.StateDescription = 'Update is required')
order by DeviceName, Title"
		if ($ScriptParams.Credential) {
			$res = @(Invoke-DbaQuery -SqlInstance $ScriptParams.SqlInstance -Database $ScriptParams.Database -Query $query -SqlCredential $ScriptParams.Credential)
		} else {
			$res = @(Invoke-DbaQuery -SqlInstance $ScriptParams.SqlInstance -Database $ScriptParams.Database -Query $query)
		}
		
		if ($res.Count -gt 0) {
			$stat = "WARNING" # or "FAIL"
			$msg  = "$($res.Count) items found"
			$res | Foreach-Object {
				$dataset = @($_.DeviceName, $_.ArticleID, $_.Title, $_.LastErrorCode)
				$tempdata.Add($dataset)
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
			TestData    = $tempdata
			Description = $Description
			Status      = $stat 
			Message     = $msg
			Credential  = $(if($ScriptParams.Credential){$($ScriptParams.Credential).UserName} else { $env:USERNAME })
		})
	}
}
