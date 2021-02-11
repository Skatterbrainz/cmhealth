function Test-SqlServerMemory {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Test-SqlServerMemory",
		[parameter()][string] $TestGroup = "database",
		[parameter()][string] $Description = "Validate maximum memory allocation of SQL instance",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		$startTime = (Get-Date)
		[int]$MaxMemAllocation = Get-CmHealthDefaultValue -KeySet "sqlserver:MaxMemAllocationPercent" -DataSet $CmHealthConfig
		Write-Verbose "MaxMemAllocation = $MaxMemAllocation"
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat   = "PASS"
		$except = "FAIL"
		$msg    = "No issues found"
		$unlimited = 2147483647
		# get total memory allocated to SQL Server in MB
		if ($null -ne $ScriptParams.Credential) {
			$cmax = (Get-DbaMaxMemory -SqlInstance $ScriptParams.SqlInstance -EnableException -ErrorAction Stop -SqlCredential $ScriptParams.Credential).MaxValue
		} else {
			$cmax = (Get-DbaMaxMemory -SqlInstance $ScriptParams.SqlInstance -EnableException -ErrorAction Stop).MaxValue
		}
		Write-Verbose "current sql limit = $cmax MB"
		# get total physical memory of host in MB
		if ($ScriptParams.Credential) {
			$tmem = (Get-DbaComputerSystem -ComputerName $ScriptParams.SqlInstance -EnableException -ErrorAction SilentlyContinue -Credential $ScriptParams.Credential).TotalPhysicalMemory.Megabyte
		} else {
			$tmem = (Get-DbaComputerSystem -ComputerName $ScriptParams.SqlInstance -EnableException -ErrorAction SilentlyContinue).TotalPhysicalMemory.Megabyte
		}
		Write-Verbose "total physical memory = $tmem MB"
		$target = $tmem * $($MaxMemAllocation * 0.1)
		Write-Verbose "target memory = $target"
		$target = [math]::Round($target, 0)
		Write-Verbose "target memory = $target (rounded)"
		if ($cmax -eq $unlimited) {
			$stat = $except
			$msg  = "Current SQL Server max memory is unlimited. Should be limited to $MaxMemAllocation percent of total physical memory."
		} else {
			if ($cmax -gt $tmem) {
				$stat = $except
				$msg  = "Current limit $($cmax) MB is greater than physical $($tmem) MB - possibly due to virtual dynamic memory"
			} elseif ($cmax -gt $target) {
				$stat = "WARNING"
				$msg  = "Current limit $($cmax) MB is greater than $MaxMemAllocation percent physical $($tmem) MB or $($target) MB"
			}
		}
		if ($Remediate -eq $True) {
			if ($ScriptParams.Credential) {
				Set-DbaMaxMemory -SqlInstance $ScriptParams.SqlInstance -Max $target -EnableException -ErrorAction SilentlyContinue -SqlCredential $ScriptParams.Credential
			} else {
				Set-DbaMaxMemory -SqlInstance $ScriptParams.SqlInstance -Max $target -EnableException -ErrorAction SilentlyContinue
			}
			$stat = 'REMEDIATED'
			$msg  = "SQL Server max memory is now set to $target MB"
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
