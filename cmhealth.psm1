('public','private','tests') | Foreach-Object {
	Get-ChildItem -Path (Join-Path $PSScriptRoot -ChildPath $_) -Filter "*.ps1" | Foreach-Object { . $_.FullName }
}
