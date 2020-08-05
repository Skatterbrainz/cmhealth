# Module manifest for module 'cmhealth'
# Generated on: 03/04/2020 
# Last updated: 08/05/2020 

@{
RootModule = '.\cmhealth.psm1'
ModuleVersion = '0.0.2.9'
# CompatiblePSEditions = @()
GUID = '3a1b9863-6418-4e82-b516-97720283ad3d'
Author = 'David Stein, Chad Simmons, YourNameHere'
CompanyName = 'Skatterbrainz'
Copyright = '(c) 2020 Skatterbrainz. All rights reserved.'
Description = 'Microsoft Endpoint Manager Configuration Manager Site Health Assessment Tools'
# PowerShellVersion = ''
# PowerShellHostName = ''
# PowerShellHostVersion = ''
# DotNetFrameworkVersion = ''
# CLRVersion = ''
# ProcessorArchitecture = ''
RequiredModules = @('dbatools','carbon','adsips')
# RequiredAssemblies = @()
# ScriptsToProcess = @()
# TypesToProcess = @()
# FormatsToProcess = @()
# NestedModules = @()
FunctionsToExport = @('Test-CmHealth')
CmdletsToExport = '*'
VariablesToExport = '*'
AliasesToExport = '*'
# DscResourcesToExport = @()
# ModuleList = @()
# FileList = @()
PrivateData = @{
    PSData = @{
        Tags = @('cmhealth','configmgr','configuration manager','sccm','mecm','memcm','systemcenter','health','sql','catapult','endpoint','microsoft','devices','database')
        LicenseUri = 'https://github.com/Skatterbrainz/cmhealth'
        ProjectUri = 'https://github.com/Skatterbrainz/cmhealth'
        # IconUri = ''
        ReleaseNotes = 'https://github.com/Skatterbrainz/cmhealth'
    } # End of PSData hashtable
} # End of PrivateData hashtable
# HelpInfoURI = ''
# DefaultCommandPrefix = ''
}
