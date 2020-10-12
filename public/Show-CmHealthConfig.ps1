function Get-CmHealthConfig {
	param()
	$Script:CmHealthConfig = Import-CmHealthSettings
	$Script:CmHealthConfig
}