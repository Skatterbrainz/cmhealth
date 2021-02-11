function Test-CmBoundariesDuplicates {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Test-CmBoundariesDuplicates",
		[parameter()][string] $TestGroup = "configuration",
		[parameter()][string] $Description = "Validate Site Boundaries are not duplicated",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat   = "PASS"
		$except = "FAIL"
		$msg   = "No issues found"
		$query = "select * from vSMS_Boundary"
		if ($ScriptParams.Credential) {
			$boundaries = @(Invoke-DbaQuery -SqlInstance $ScriptParams.SqlInstance -Database $ScriptParams.Database -Query $query -SqlCredential $ScriptParams.Credential)
		} else {
			$boundaries = @(Invoke-DbaQuery -SqlInstance $ScriptParams.SqlInstance -Database $ScriptParams.Database -Query $query)
		}
		$dupes = @($boundaries | Group-Object -Property BoundaryType,Value | Select-Object Count,Name)
		if (($dupes | Where-Object {$_.Count -gt 1}) -gt 0) {
			$stat = $except
			foreach ($dupe in $dupes) {
				$tempData.Add([pscustomobject]@{Boundary=$($dupe.Name);Count=$($dupe.Count)})
			}
		}
	}
	catch {
		$stat = 'ERROR'
		$msg = $_.Exception.Message -join ';'
	}
	finally {
		$endTime = (Get-Date)
		$runTime = $(New-TimeSpan -Start $startTime -End $endTime)
		$rt = "{0}h:{1}m:{2}s" -f $($runTime | Foreach-Object {$_.Hours,$_.Minutes,$_.Seconds})
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
