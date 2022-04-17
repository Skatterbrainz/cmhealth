function Test-CmHealthDependencies {
<#
.SYNOPSIS
	Check (and update) dependent PowerShell modules
.DESCRIPTION
	Check current install versions of dependent PowerShell modules against
	PowerShell Gallery and update them if desired
.PARAMETER Update
	Optional. Update modules which older than PS Gallery versions
.EXAMPLE
	Test-CmHealthDependencies
	Returns status of installed modules which are used by CMHealth
.EXAMPLE
	Test-CmHealthDependencies -Update
	Updates installed modules used by CMHealth if they are older than published on PS Galler
.LINK
	https://github.com/Skatterbrainz/cmhealth/blob/master/docs/Test-CmHealthDependencies.md
#>
[CmdletBinding()]
	[OutputType()]
	param()
	Write-Host "checking dependencie module versions" -ForegroundColor Cyan
	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
	$modules = @('dbatools','carbon','adsips','pswindowsupdate')
	foreach ($module in $modules) {
		$iv = $(Get-Module $module -ListAvailable | Select-Object -First 1 -ExpandProperty Version) -join '.'
		$gv = $(Find-Module $module | Select-Object -ExpandProperty Version) -join '.'
		[pscustomobject]@{
			Module = $module
			Installed = $iv
			Gallery = $gv
			IsCurrent = $([version]$iv -ge [version]$gv)
		}
	}
}