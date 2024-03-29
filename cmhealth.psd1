# Module manifest for module 'cmhealth'
# Generated on: 03/04/2020
# Last updated: 04/29/2022

@{
RootModule = '.\cmhealth.psm1'
ModuleVersion = '1.0.6'
# CompatiblePSEditions = @()
GUID = '3a1b9863-6418-4e82-b516-97720283ad3d'
Author = 'David Stein'
CompanyName = 'Skatterbrainz'
Copyright = '(c) 2020-2022 David M. Stein. All rights reserved.'
Description = 'Microsoft Endpoint Manager Configuration Manager Site Health Assessment Tools.Special thanks to contributions from Chad Simmons and Phil Pritchett'
# PowerShellVersion = ''
# PowerShellHostName = ''
# PowerShellHostVersion = ''
# DotNetFrameworkVersion = ''
# CLRVersion = ''
# ProcessorArchitecture = ''
RequiredModules = @('dbatools','carbon','pswindowsupdate','adsips')
# RequiredAssemblies = @()
# ScriptsToProcess = @()
# TypesToProcess = @()
# FormatsToProcess = @()
# NestedModules = @()
FunctionsToExport = @(
	'Test-CmHealth','Show-CmHealthConfig','Out-CmHealthReport','Get-CmHealthTests',
	'Invoke-CmHealthTests','Test-CmHealthDependencies','Reset-CmHealthConfig'
)
CmdletsToExport = '*'
VariablesToExport = '*'
AliasesToExport = '*'
# DscResourcesToExport = @()
# ModuleList = @()
# FileList = @()
PrivateData = @{
	PSData = @{
		Tags = @('cmhealth','configmgr','sccm','mecm','memcm','systemcenter','health','healthcheck',
			'sql','catapult','endpoint','microsoft','devices','database','skatterbrainz'
		)
		LicenseUri = 'https://github.com/Skatterbrainz/cmhealth'
		ProjectUri = 'https://github.com/Skatterbrainz/cmhealth'
		IconUri = 'https://user-images.githubusercontent.com/11505001/32978293-2be8336e-cc0d-11e7-9606-0c3412aaa7cc.png'
		ReleaseNotes = 'https://github.com/Skatterbrainz/cmhealth'
	} # End of PSData hashtable
} # End of PrivateData hashtable
# HelpInfoURI = ''
# DefaultCommandPrefix = ''
}
