function Test-SqlDbFileGrowth {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "SQL Database File Growth",
		[parameter()][string] $TestGroup = "configuration",
		[parameter()][string] $TestCategory = "SQL",
		[parameter()][string] $Description = "Validate SQL Database File Auto-Growth settings",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		$startTime = (Get-Date)
		Write-Warning "$TestName - THIS TEST IS NOT COMPLETE - PLEASE CONSIDER CONTRIBUTING?"
		$stat   = "PASS"
		$except = "WARNING"
		$msg    = "No issues found"
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed

		<#
ComputerName             : SIDE-SC01
InstanceName             : MSSQLSERVER
SqlInstance              : SIDE-SC01
Database                 : CM_SIA
FileGroupName            : PRIMARY
ID                       : 1
Type                     : 0
TypeDescription          : ROWS
LogicalName              : CM_SIA
PhysicalName             : H:\Microsoft SQL Server\Data\CM_SIA.mdf
State                    : ONLINE
MaxSize                  : Unlimited
Growth                   : 2 <-- should be calculated value based on initial DB size (clients x 5mb + 5G)
GrowthType               : Percent <-- should be size/MB
NextGrowthEventSize      : 244.77 MB
Size                     : 11.95 GB
UsedSpace                : 10.00 GB
AvailableSpace           : 1.95 GB
IsOffline                : False
IsReadOnly               : False
IsReadOnlyMedia          : False
IsSparse                 : False
NumberOfDiskWrites       : 3050621
NumberOfDiskReads        : 771039
ReadFromDisk             : 144.92 GB
WrittenToDisk            : 46.83 GB
VolumeFreeSpace          : 121.85 GB
FileGroupDataSpaceId     : 1
FileGroupType            : FG
FileGroupTypeDescription : ROWS_FILEGROUP
FileGroupDefault         : True
FileGroupReadOnly        : False

ComputerName             : SIDE-SC01
InstanceName             : MSSQLSERVER
SqlInstance              : SIDE-SC01
Database                 : CM_SIA
FileGroupName            :
ID                       : 2
Type                     : 1
TypeDescription          : LOG
LogicalName              : CM_SIA_log
PhysicalName             : H:\Microsoft SQL Server\Data\CM_SIA_log.ldf
State                    : ONLINE
MaxSize                  : 2.00 TB
Growth                   : 65536
GrowthType               : kb
NextGrowthEventSize      : 64.00 MB
Size                     : 3.76 GB
UsedSpace                : 81.63 MB
AvailableSpace           : 3.68 GB
IsOffline                : False
IsReadOnly               : False
IsReadOnlyMedia          : False
IsSparse                 : False
NumberOfDiskWrites       : 3744695
NumberOfDiskReads        : 685
ReadFromDisk             : 528.74 MB
WrittenToDisk            : 26.11 GB
VolumeFreeSpace          : 121.85 GB
FileGroupDataSpaceId     :
FileGroupType            :
FileGroupTypeDescription :
FileGroupDefault         :
FileGroupReadOnly        :
		#>
		if ($ScriptParams.Credential) {
			$dbfiles = Get-DbaDbFile -SqlInstance $ScriptParams.SqlInstance -Database $ScriptParams.Database -SqlCredential $ScriptParams.Credential
		} else {
			$dbfiles = Get-DbaDbFile -SqlInstance $ScriptParams.SqlInstance -Database $ScriptParams.Database
		}
		$procs = Get-WmiQueryResult -ClassName "Win32_Processor" -Params $ScriptParams

		$query = "select distinct Name from v_CombinedDeviceResources where (Name not like '%Unknown%') and (Name not like 'Provisioning Device%')"
		if ($null -ne $ScriptParams.Credential) {
			$clients = @(Invoke-DbaQuery -SqlInstance $ScriptParams.SqlInstance -Database $ScriptParams.Database -Query $query -SqlCredential $ScriptParams.Credential).Count
		} else {
			$clients = @(Invoke-DbaQuery -SqlInstance $ScriptParams.SqlInstance -Database $ScriptParams.Database -Query $query).Count
		}
		Write-Verbose "clients = $clients"
		switch ($ScriptParams.FileType) {
			'Database' {
				$files = $dbfiles | Where-Object {$_.TypeDescription -eq 'Rows'}
				$test1 = $files | Where-Object {$_.GrowthType -eq 'Percent' -and $_.Growth -ge 10}
				$test2 = $files | Where-Object {$_.GrowthType -eq '' -and $_.Growth -ge 256}

				# more work needed here!
			}
			'Log' {
				# more work needed here!
			}
		} # switch

	}
	catch {
		$stat = 'ERROR'
		$msg = $_.Exception.Message -join ';'
	}
	finally {
		Write-Output $([pscustomobject]@{
			Computer    = $ScriptParams.ComputerName
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
