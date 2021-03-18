try {
    $mv = Get-Module cmhealth -ListAvailable | Select-Object -First 1 -ExpandProperty Version
    if ($null -ne $mv) {
        $mv = $mv -join '.'
        $fv = Find-Module cmhealth | Select-Object -ExpandProperty Version
        if ([version]$fv -gt [version]$mv) {
            Write-Warning "a newer version is available"
        } else {
            Write-Host "cmhealth version $mv is the latest available" -ForegroundColor Green
        }
    }
}
catch {}