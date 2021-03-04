function Test-CmSqlDbReplicationStatus {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "CM Database Replication Status",
		[parameter()][string] $TestGroup = "operation",
		[parameter()][string] $Description = "Check for SQL Replication Errors and Warnings",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		$startTime = (Get-Date)
		#[int]$Setting = Get-CmHealthDefaultValue -KeySet "keygroup:keyname" -DataSet $CmHealthConfig
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat   = "PASS" # do not change this
		$except = "WARNING" # or "FAIL"
		$msg    = "No issues found" # do not change this either
		<#
		=======================================================
		|	COMMENT: DELETE THIS BLOCK WHEN FINISHED:
		|
		|	perform test and return result as an object...
		|		$stat = $except (no need to set "PASS" since it's the default)
		|		$msg = "custom message that N issues were found"
		|		add supporting data to $tempdata array if it helps output
		|		loop output into $tempdata.Add() array to return as TestData param in output
		=======================================================
		#>

		<#
		=======================================================
		COMMENT: EXAMPLE FOR SQL QUERY RELATED TESTS... DELETE THIS BLOCK IF NOT USED
		=======================================================

		$query = ""
		$res = Get-CmSqlQueryResult -Query $query -Params $ScriptParams
		if ($res.Count -gt 0) {
			$stat = $except
			$msg  = "$($res.Count) items found"
			#$res | Foreach-Object {$tempdata.Add( [pscustomobject]@{Name=$_.Name} )}
		}
		=======================================================
		#>
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
