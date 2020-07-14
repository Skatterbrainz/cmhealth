function Test-Example {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "SQL Server Max Memory Allocation",
		[parameter()][string] $TestGroup = "database",
		[parameter()][string] $Description = "Validate maximum memory allocation of SQL instance",
		[parameter()][bool] $Remediate = $False,
		[parameter()][string] $SqlInstance = "localhost",
		[parameter()][string] $Database = "",
		[parameter()][int] $MaxMemAllocation = 0.8
	)
	try {
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat = "PASS"
		$unlimited = 2147483647
		# get total memory allocated to SQL Server in MB
		$cmax = (Get-DbaMaxMemory -SqlInstance $SqlInstance -EnableException -ErrorAction SilentlyContinue).MaxValue
		# get total physical memory of host in MB
		$tmem = (Get-DbaComputerSystem -ComputerName $SqlInstance -EnableException -ErrorAction SilentlyContinue).TotalPhysicalMemory.Megabyte
		$target = $tmem * ($MaxMemAllocation / 100)
		$target = [math]::Round($target / 1MB, 0)
		if ($cmax -eq $unlimited) {
			$stat = 'FAIL'
			$msg  = "Current SQL Server max memory is unlimited. Should be $target MB"
		} else {
			if ($cmax -ne $target) {
				$stat = 'FAIL'
				$msg =  "Current SQL Server max memory is constrained to $($cmax). Should be $target MB"
			}
		}
		if ($Remediate -eq $True) {
			Set-DbaMaxMemory -SqlInstance $SqlInstance -Max $target -EnableException -ErrorAction SilentlyContinue
			$stat = 'REMEDIATED'
			$msg  = "SQL Server max memory is now set to $target MB"
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
		})
	}
}
