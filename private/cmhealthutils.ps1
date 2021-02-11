function Import-CmHealthSettings {
	[CmdletBinding()]
	param (
		[parameter()][string] $Primary = "$($env:USERPROFILE)\Desktop\cmhealth.json",
		[parameter()][string] $Default = "$(Split-Path $(Get-Module cmhealth).Path)\reserve\cmhealth.json"
	)
	try {
		if (Test-Path $Primary) {
			Write-Verbose "loading from: $Primary"
			$result = Get-Content -Path $Primary | ConvertFrom-Json
		} elseif (Test-Path $Default) {
			Write-Verbose "loading from: $Default"
			$result = Get-Content -Path $Default | ConvertFrom-Json
		} else {
			throw "cmhealth.json was not found"
		}
	}
	catch {
		Write-Error $_.Exception.Message
	}
	finally {
		Write-Output $result
	}
}

function Get-CmHealthDefaultValue {
	[CmdletBinding()]
	param (
		[parameter(Mandatory)][ValidateNotNullOrEmpty()][string] $KeySet,
		[parameter(Mandatory)][ValidateNotNullOrEmpty()] $DataSet
	)
	try {
		$keydef = $KeySet -split ':'
		if ($keydef.Count -gt 1) {
			$keyname = $keydef[0]
			$value   = $keydef[1]
			$result  = $DataSet."$keyname"."$value"
		} else {
			$result = $DataSet."$keydef"
		}
	}
	catch {
		Write-Error $_.Exception.Message
	}
	finally {
		Write-Output $result
	}
}

function Get-CmHealthLastTestSet {
	[CmdletBinding()]
	param()
	$filepath = Join-Path -Path $env:USERPROFILE -ChildPath "desktop\cmhealth-lastrun.txt"
	if (Test-Path $filepath) {
		Write-Verbose "importing test selection from $filepath"
		Write-Output $(Get-Content -Path $filepath)
	} else {
		Write-Warning "No previous tests have been completed. Run some tests first."
	}
}

function Set-CmHealthLastTestSet {
	[CmdletBinding()]
	param(
		[parameter(Mandatory=$True)][string[]] $TestNames,
		[parameter(Mandatory=$False)][string] $FilePath = "$($env:USERPROFILE)\Desktop\cmhealth-lastrun.txt"
	)
	Write-Verbose "saving test selection to $FilePath"
	$TestNames | Out-File -FilePath $FilePath -Force
}

function Get-CmSqlQueryResult {
	[CmdletBinding()]
	param (
		[parameter(Mandatory=$True)][ValidateNotNullOrEmpty()][string] $Query,
		[parameter(Mandatory=$True)] $Params
	)
	if ($null -ne $Params.Credential) {
		Write-Verbose "submitting query with credentials"
		$result = @(Invoke-DbaQuery -SqlInstance $Params.SqlInstance -Database $Params.Database -Query $Query -SqlCredential $Params.Credential)
	} else {
		Write-Verbose "submitting query without credentials"
		$result = @(Invoke-DbaQuery -SqlInstance $Params.SqlInstance -Database $Params.Database -Query $Query)
	}
	$result
}