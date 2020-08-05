function Test-WsusIisAppPoolSettings {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Test-WsusIisAppPoolSettings",
		[parameter()][string] $TestGroup = "configuration",
		[parameter()][string] $Description = "Validate WSUS IIS application pool settings",
		[parameter()][hashtable] $ScriptParams,
		[parameter()][int32] $QueueLength = 2000,
		[parameter()][int32] $PrivateMemLimit = 7372800
	)
	try {
		$stat = "PASS"
		$msg = "No issues found"
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$oldLoc = $(Get-Location).Path
		if (!(Get-Module WebAdministration -ListAvailable)) { throw "WebAdministration module not installed. Please install RSAT" }
		Import-Module WebAdministration
		$WsusAppPool = Get-ItemProperty IIS:\AppPools\WsusPool
		Write-Verbose "recommended queue length: $QueueLength"
		$cql = $(Get-ItemProperty IIS:\AppPools\WsusPool\).queueLength
		if ($cql -ne $QueueLength) {
			if ($ScriptParams.Remediate -eq $True) {
				Set-ItemProperty -Path $WsusAppPool.PSPath -Name queueLength -Value $QueueLength
				$tempdata.Add([pscustomobject]@{
					Test    = "QueueLength"
					Status  = "REMEDIATED"
					Message = "new queue length: $((Get-ItemProperty IIS:\AppPools\WsusPool\).queueLength)"
				})
				$stat = "REMEDIATED"
				$msg  = "QueueLenght has been updated to $QueueLength"
			}
			else {
				$tempdata.Add([pscustomobject]@{
					Test    = "QueueLength"
					Status  = "FAIL"
					Message = "queue length is currently: $cql.  Should be $QueueLength"
				})
				$stat = "FAIL"
				$msg = "Queuelength is incorrect"
			}
		}
		else {
			$tempdata.Add([pscustomobject]@{
				Test    = "QueueLength"
				Status  = "PASS"
				Message = "queue length is currently set to: $cql"
			})
		}
		$applicationPoolsPath = "/system.applicationHost/applicationPools"
		$applicationPools = Get-WebConfiguration $applicationPoolsPath
		foreach ($appPool in $applicationPools.Collection) {
			$appPoolPath = "$applicationPoolsPath/add[@name='$($appPool.Name)']"
			if ($appPool.Name -eq 'WsusPool') {
				Write-Verbose "recommended private memory limit: $PrivateMemLimit"
				$cpm = $(Get-WebConfiguration "$appPoolPath/recycling/periodicRestart/@privateMemory").Value
				Write-Verbose "current private memory limit: $cpm"
				if ($cpm -ne $PrivateMemLimit) {
					if ($ScriptParams.Remediate -eq $True) {
						Set-WebConfiguration "$appPoolPath/recycling/periodicRestart/@privateMemory" -Value $PrivateMemLimit
						$newpm = Get-WebConfiguration "$appPoolPath/recycling/periodicRestart/@privateMemory" 
						$tempdata.Add([pscustomobject]@{
							Test    = "PrivateMemLimit"
							Status  = "REMEDIATED"
							Message = "new private memory limit: $newpm"
						})
						$stat = "REMEDIATED"
						$msg = "PrivateMemLimit has been updated to $PrivateMemLimit"
					}
					else {
						$tempdata.Add([pscustomobject]@{
							Test    = "PrivateMemLimit"
							Status  = "FAIL"
							Message = "private memory limit is set to: $cpm.  Should be $PrivateMemLimit"
						})
						$stat = "FAIL"
						$msg = "PrivateMemLimit is incorrect"
					}
				}
				else {
					$tempdata.Add([pscustomobject]@{
						Test    = "PrivateMemLimit"
						Status  = "PASS"
						Message = "private memory limit is currently set to: $cpm"
					})
				}
			}
		}
	}
	catch {
		$stat = 'ERROR'
		$msg = $_.Exception.Message -join ';'
	}
	finally {
		Set-Location $oldLoc
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
