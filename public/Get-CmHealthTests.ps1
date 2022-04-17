function Get-CmHealthTests {
<#
.SYNOPSIS
	Display CMHealth Tests and description info
.DESCRIPTION
	Display CMHealth tests and additional descriptive information
.EXAMPLE
	Get-CmHealthTests
.NOTES
	Added in 0.3.8
.LINK
	https://github.com/Skatterbrainz/cmhealth/blob/master/docs/Get-CmHealthTests.md
#>
[CmdletBinding()]
	[OutputType()]
	param()
	$mpath = $(Split-Path (Get-Module cmhealth).Path)
	$tpath = "$($mpath)\tests"
	$tests = Get-ChildItem -Path $tpath -Filter "*.ps1" -ErrorAction Stop
	foreach ($test in $tests) {
		. $test.FullName
		$basename = $test.BaseName
		$ast = (Get-Command $basename).ScriptBlock.Ast
		$x = $ast.Body.ParamBlock.Parameters.Extent.Text
		$testname  = $x[0].Split('=')[1].Trim()
		$testgroup = $x[1].Split('=')[1].Trim()
		$testdesc  = $x[2].Split('=')[1].Trim()
		switch ($basename.Substring(5,2)) {
			'ad' { $type = 'AD' }
			'cm' { $type = 'CM' }
			'sq' { $type = 'SQL' }
			'ii' { $type = 'IIS' }
			'ho' { $type = 'Host' }
			default { $basename.Substring(5,2) }
		}
		[pscustomobject]@{
			Test  = $basename
			Name  = $testname.Replace('"', '')
			Group = $testgroup.Replace('"', '')
			Type  = $type
			Description = $testdesc.Replace('"', '')
		}
	}
}