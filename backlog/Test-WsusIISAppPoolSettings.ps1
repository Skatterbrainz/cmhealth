function Test-WsusIisAppPoolSettings {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "WSUS IIS Application Pool Settings",
		[parameter()][string] $TestGroup = "configuration",
		[parameter()][string] $TestCategory = "HOST",
		[parameter()][string] $Description = "Validate WSUS IIS application pool settings",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		$startTime = (Get-Date)
		[int32]$QueueLength = Get-CmHealthDefaultValue -KeySet "wsus:QueueLength" -DataSet $CmHealthConfig
		[int32]$PrivateMemLimit = Get-CmHealthDefaultValue -KeySet "wsus:PrivateMemLimit" -DataSet $CmHealthConfig
		$stat   = "PASS"
		$except = "WARNING"
		$msg    = "No issues found"
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
					Status  = $except
					Message = "queue length is currently: $cql.  Should be $QueueLength"
				})
				$stat = $except
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
							Status  = $except
							Message = "private memory limit is set to: $cpm.  Should be $PrivateMemLimit"
						})
						$stat = $except
						$msg  = "PrivateMemLimit is incorrect"
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
		$([pscustomobject]@{
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
