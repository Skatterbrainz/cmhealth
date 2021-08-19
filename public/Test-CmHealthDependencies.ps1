function Test-CmHealthDependencies {
	[CmdletBinding()]
	param()
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