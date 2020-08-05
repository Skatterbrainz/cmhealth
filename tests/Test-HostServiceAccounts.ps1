function Test-HostServiceAccounts {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Test-HostServiceAccounts",
		[parameter()][string] $TestGroup = "configuration",
		[parameter()][string] $Description = "Validate services accounts and permissions",
		[parameter()][hashtable] $ScriptParams
	)
	$privs = ('SeServiceLogonRight','SeAssignPrimaryTokenPrivilege','SeChangeNotifyPrivilege','SeIncreaseQuotaPrivilege')
	$builtin = ('LocalSystem','NT AUTHORITY\NetworkService','NT AUTHORITY\LocalService')
	try {
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat = "PASS"
		$msg = "No issues found"
		$mpath = Split-Path (Get-Module CMhealth).Path -Parent
		$jfile = "$mpath\tests\services.json"
		if (!(Test-Path $jfile)) { throw "file not found: $jfile" }
		Write-Verbose "loading configuration file: $jfile"
		$jdata = Get-Content $jfile | ConvertFrom-Json
		if ($ScriptParams.Credential) {
			$cs = New-CimSession -ComputerName $ScriptParams.ComputerName -Authentication Negotiate -Credential $ScriptParams.Credential -ErrorAction Stop
		}
		$jdata.Services | ForEach-Object {
			$svcName = $_.Name 
			$svcRef  = $_.Reference 
			$privs   = $_.Privileges
			$startup = $_.StartMode
			$delayed = if ($_.DelayedAutoStart -eq 'true') { $True } else { $False }
			Write-Verbose "service name: $svcName"
			try {
				if ($ScriptParams.Credential) {
					$svc = Get-CimInstance -ClassName Win32_Service -Filter "Name = '$svcName'" -CimSession $cs 
				} else {
					$svc = Get-CimInstance -ClassName Win32_Service -Filter "Name = '$svcName'" -ComputerName $ScriptParams.ComputerName
				}
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
							$res  = 'FAIL'
							$stat = 'FAIL' 
							$msgx = 'Insufficient privileges'
						} else {
							$res  = 'PASS'
							$msgx = 'Correct configuration'
						}
						Write-Verbose "service account privileges: $res"
						if ($svcStart -ne $startup) { 
							$res  = 'FAIL'
							$stat = 'FAIL' 
							$msgx = 'Startup type'
						} else {
							$res  = 'PASS'
							$msgx = 'Correct configuration'
						}
						Write-Verbose "startup mode = $res"
						if ($svcDelay -ne $delayed) { 
							$res  = 'FAIL'
							$stat = 'FAIL'
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
			Credential  = $(if($ScriptParams.Credential){$($ScriptParams.Credential).UserName} else { $env:USERNAME })
		})
	}
}
