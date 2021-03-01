function Test-HostServiceAccounts {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Service Account Permissions",
		[parameter()][string] $TestGroup = "configuration",
		[parameter()][string] $Description = "Validate services accounts and permissions",
		[parameter()][hashtable] $ScriptParams
	)
	$privs = ('SeServiceLogonRight','SeAssignPrimaryTokenPrivilege','SeChangeNotifyPrivilege','SeIncreaseQuotaPrivilege')
	$builtin = ('LocalSystem','NT AUTHORITY\NetworkService','NT AUTHORITY\LocalService')
	try {
		$startTime = (Get-Date)
		$svcConfig = @(Get-CmHealthDefaultValue -KeySet "services" -DataSet $CmHealthConfig)
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat   = "PASS"
		$except = "FAIL"
		$msg    = "No issues found"
		foreach ($service in $svcConfig) {
			$svcName = $service.Name
			$svcRef  = $service.Reference
			$privs   = $service.Privileges
			$startup = $service.StartMode
			$delayed = if ($service.DelayedAutoStart -eq 'true') { $True } else { $False }
			Write-Verbose "service name: $svcName"
			try {
				$svc = Get-WmiQueryResult -ClassName "Win32_Service" -Query "Name = '$svcName'" -Params $ScriptParams
				$svcAcct  = $svc.StartName
				$svcStart = $svc.StartMode
				$svcDelay = $svc.DelayedAutoStart
				Write-Verbose "checking service account: $svcAcct"
				if ($svcAcct -in $builtin) {
					Write-Verbose "built-in account with default privileges"
				}
				else {
					$cprivs = Get-CPrivilege -Identity $svcAcct
					$privs -split ',' | Foreach-Object {
						$priv = $_
						if ($priv -notin $cprivs) {
							$res  = $except
							$stat = $except
							$msgx = 'Insufficient privileges'
						} else {
							$res  = 'PASS'
							$msgx = 'Correct configuration'
						}
						Write-Verbose "service account privileges: $res"
						if ($svcStart -ne $startup) {
							$res  = $except
							$stat = $except
							$msgx = 'Startup type'
						} else {
							$res  = 'PASS'
							$msgx = 'Correct configuration'
						}
						Write-Verbose "startup mode = $res"
						if ($svcDelay -ne $delayed) {
							$res  = $except
							$stat = $except
							$msgx = 'Delayed start'
						} else {
							$res  = 'PASS'
							$msgx = 'Correct configuration'
						}
						Write-Verbose "startup delay = $res"
						$tempdata.Add([pscustomobject]@{
							ServiceName = $svcName
							ServiceAcct = $svcAcct
							Reference   = $svcRef
							Privilege   = $priv
							StartMode   = $startup
							DelayStart  = $delayed
							Compliant   = $res
							Status      = $stat
							Reason      = $msgx
						})
					}
				}
			}
			catch {
				Write-Error "$svcName = $($_.Exception.Message -join ';')"
			}
		}
	}
	catch {
		$stat = 'ERROR'
		$msg  = $_.Exception.Message -join ';'
	}
	finally {
		if ($cs) { $cs.Close(); $cs = $null }
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
