function Test-CmHealth {
	[CmdletBinding()]
	param (
		[parameter(Mandatory)][ValidateNotNullOrEmpty()][string] $SiteServer,
		[parameter(Mandatory)][ValidateLength(3,3)][string] $SiteCode,
		[parameter()][string] $Database = "CM_$SiteCode",
		[parameter()][string] $OutputFolder = "$($env:USERPROFILE)\Documents"
	)
	$filepath = "$OutputFolder\$SiteServer`_$(Get-Date -f 'yyyy-MM-dd').htm"
	Write-Verbose "report file: $filepath"
	$Global:cmhealthParams = @{
		ComputerName = $SiteServer
		SiteServer   = $SiteServer
		SqlInstance  = $SqlInstance
		SiteCode     = $SiteCode
		Database     = $Database
	}
	try {
		$mpath = Split-Path (Get-Module "cmhealth").Path -Parent
		$testFiles = Get-ChildItem -Path "$mpath\tests" -Filter "*.ps1"
		foreach ($test in $testfiles) {
			$fpath = $test.FullName
			$testResult = Start-Process -FilePath $fpath -NoNewWindow -PassThru
		}
		Write-Verbose "converting content to HTML..."
		$body = $output -join '' | ConvertTo-Html -Fragment
		Write-Host "Saving report to file: $filepath" -ForegroundColor Cyan
		ConvertTo-HTML -InputObject $body -Title "MECM Health Report: $SiteServer" -CssUri ".\default.css" |
			Out-File -FilePath $filepath -Force
		Write-Host "Opening report in browser..." -ForegroundColor Cyan
		Start-Process $filepath
	}
	catch {}
}