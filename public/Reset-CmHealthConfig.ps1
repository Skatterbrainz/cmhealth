function Reset-CmHealthConfig {
<#
.SYNOPSIS
	Replace existing cmhealth.json with default template
.DESCRIPTION
	Replace existing cmhealth.json with default template
.PARAMETER ConfigFile
	Path and filename to cmhealth.json
.NOTES
	Thank you again!
.LINK
	https://github.com/Skatterbrainz/cmhealth/blob/master/docs/Reset-CmHealthConfig.md
#>
[CmdletBinding()]
	[OutputType()]
	param (
		[parameter(Mandatory=$False)][string]$ConfigFile = "$($env:TEMP)\cmhealth.json"
	)
	if (Test-Path $ConfigFile) { 
		Write-Verbose "removing cmhealth settings file: $($ConfigFile)"
		Get-Item -Path $ConfigFile | Remove-Item -Force 
	}
	if ([string]::IsNullOrEmpty($LogFile)) {
		$LogFile = "$($env:TEMP)\cmhealth_$(Get-Date -f 'yyyy-MM-dd').log"
	}
	New-CmHealthConfig -Path $ConfigFile
	Write-Host "$ConfigFile has been reset to default values" -ForegroundColor Cyan
}
