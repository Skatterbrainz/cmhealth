function Test-ServerFeatures {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Windows Server Features",
		[parameter()][string] $TestGroup = "configuration",
		[parameter()][string] $Description = "Validate Windows Server roles and features for CM site systems",
		[parameter()][hashtable] $ScriptParams,
		[parameter()][string] $Source = ""
	)
	try {
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat = "PASS"
		$msg = "No issues found"
		Import-Module ServerManager
		$features = Get-WindowsFeature
		$LogFile = Join-Path $env:TEMP "serverfeatures.log"
		if ($Remediate -eq $True -and ([string]::IsNullOrEmpty($Source))) {
			throw "Source parameter is required for -Remediate but was not specified"
		}
		$flist = @(
			'Web-Server',                     # Web Server (IIS)
			'Web-WebServer',                  # Web Server
			'Web-Common-Http',                # Common HTTP Features
			'Web-Default-Doc',                # Default Document
			'Web-Dir-Browsing',               # Directory Browsing
			'Web-Http-Errors',                # HTTP Errors
			'Web-Static-Content',             # Static Content
			'Web-Http-Redirect',              # HTTP Redirection
			'Web-Health',                     # Health and Diagnostics
			'Web-Http-Logging',               # HTTP Logging
			'Web-Log-Libraries',              # Logging Tools
			'Web-Request-Monitor',            # Request Monitor
			'Web-Http-Tracing',               # Tracing
			'Web-Performance',                # Performance
			'Web-Stat-Compression',           # Static Content Compression
			'Web-Filtering',                  # Request Filtering
			'Web-Windows-Auth',               # Windows Authentication
			'Web-Net-Ext',                    # .NET Extensibility 3.5
			'Web-Net-Ext45',                  # .NET Extensibility 4.6
			'Web-Asp-Net45',                  # ASP.NET 4.6
			'Web-ISAPI-Ext',                  # ISAPI Extensions
			'Web-ISAPI-Filter',               # ISAPI Filters
			'Web-Mgmt-Tools',                 # Management Tools
			'Web-Mgmt-Console',               # IIS Management Console
			'Web-Mgmt-Compat',                # IIS 6 Management Compatibility
			'Web-Metabase',                   # IIS 6 Metabase Compatibility
			'Web-Lgcy-Mgmt-Console',          # IIS 6 Management Console
			'Web-Lgcy-Scripting',             # IIS 6 Scripting Tools
			'Web-WMI',                        # IIS 6 WMI Compatibility
			'Web-Scripting-Tools',            # IIS Management Scripts and Tools
			'Web-Mgmt-Service',               # Management Service
			'UpdateServices-Services',        # WSUS Services
			'UpdateServices-DB',              # SQL Server Connectivity
			'NET-Framework-Features',         # .NET Framework 3.5 Features
			'NET-Framework-Core',             # .NET Framework 3.5 (includes .NET 2.0 and 3.0)
			'NET-HTTP-Activation',            # HTTP Activation
			'NET-Framework-45-Features',      # .NET Framework 4.6 Features
			'NET-Framework-45-Core',          # .NET Framework 4.6
			'NET-Framework-45-ASPNET',        # ASP.NET 4.6
			'NET-WCF-Services45',             # WCF Services
			'NET-WCF-HTTP-Activation45',      # HTTP Activation
			'NET-WCF-TCP-Activation45',       # TCP Activation
			'NET-WCF-TCP-PortSharing45',      # TCP Port Sharing
			'BITS',                           # Background Intelligent Transfer Service (BITS)
			'BITS-IIS-Ext',                   # IIS Server Extension
			'RDC',                            # Remote Differential Compression
			'WAS',                            # Windows Process Activation Service
			'WAS-Process-Model',              # Process Model
			'WAS-NET-Environment',            # .NET Environment 3.5
			'WAS-Config-APIs'                 # Configuration APIs
		)
	
		$exceptions = 0
		[System.Collections.Generic.List[PSObject]]$missing = @()
		foreach ($feature in $features) {
			if ($feature.Name -in $flist) {
				if ($feature.Installed -ne $True) {
					Write-Verbose "$($feature.Name) is not installed!"
					
					if ($Remediate -eq $True) {
						try {
							Write-Host "installing: $($Feature.Name)" -ForegroundColor Cyan
							Install-WindowsFeature -Name "$($Feature.Name)" -Source $Source -LogPath $LogFile -WarningAction SilentlyContinue -ErrorAction Stop
							$tempdata.Add([pscustomobject]@{
								Feature = $feature.Name
								Status  = "Remediated"
								Message = "Success"
							})
						}
						catch {
							$tempdata.Add([pscustomobject]@{
								Feature = $feature.Name
								Status  = "ERROR"
								Message = $_.Exception.Message -join ';'
							})
						}
					} else {
						$exceptions++
						$tempdata.Add([pscustomobject]@{
							Feature = $feature.Name 
							Statue  = "FAIL"
							Message = "Not installed"
						})
						$missing.Add($feature.Name)
					}
				}
				else {
					$tempdata.Add([pscustomobject]@{
						Feature = $feature.Name
						Status  = "PASS"
						Message = "Already installed"
					})
				}
			}
		}
		if ($exceptions -gt 0) {
			$stat = "FAIL"
			$msg  = "$exceptions features are missing: $($missing -join ',')"
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