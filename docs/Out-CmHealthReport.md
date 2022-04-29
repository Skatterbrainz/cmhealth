---
external help file: cmhealth-help.xml
Module Name: cmhealth
online version: https://github.com/Skatterbrainz/cmhealth/blob/master/docs/Out-CmHealthReport.md
schema: 2.0.0
---

# Out-CmHealthReport

## SYNOPSIS
Export CMHealth test results to HTML files

## SYNTAX

```
Out-CmHealthReport [-InputObject] <Object> [-Detailed] [[-Title] <String>] [[-CssFile] <String>]
 [[-OutputFolder] <String>] [-Show] [[-Footer] <String>] [<CommonParameters>]
```

## DESCRIPTION
Export CMHealth test results to HTML files. 
If -Detailed is invoked, each test is output
to a separate file with a parent table-of-contents (index) file providing links to each.
If -Detailed is not used, all of the tests are output to a single HTML file.

## EXAMPLES

### EXAMPLE 1
```
$testresult = Test-CmHealth -SiteCode P01 -Database CM_P01
```

$testresult | Out-CmHealthReport -Show
Create summary report and open in browser when finished

### EXAMPLE 2
```
Test-CmHealth -SiteCode P01 -Database CM_P01 | Where-Object {$_.Status -eq 'FAIL'} | Out-CmHealthReport -Show
```

Create reports for failed tests only, then open in browser when finished

### EXAMPLE 3
```
$testresult = Test-CmHealth -SiteCode P01 -Database CM_P01
```

$testresult | Out-CmHealthReport -Detailed -Title "Contoso Health Report" -Show

### EXAMPLE 4
```
$testresult = Test-CmHealth -SiteCode P01 -Database CM_P01
```

$testresult | Out-CmHealthReport -Detailed -Title "Contoso Health Report" -CssFile "c:\stylesheet.css" -Footer "Contoso Corp"

## PARAMETERS

### -InputObject
Required.
The output from from Test-CmHealth

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Detailed
Optional.
Produces verbose report files with TestData included.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Title
Optional.
Title for report heading.
Default is "CMHealth Test Results"

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: CMHealth Test Results
Accept pipeline input: False
Accept wildcard characters: False
```

### -CssFile
Optional.
Path to custom CSS stylesheet file.
If not provided, internal CSS is used by default.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OutputFolder
Optional.
Path where log file and report files are created.
Default is $env:TEMP

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: "$($env:TEMP)"
Accept pipeline input: False
Accept wildcard characters: False
```

### -Show
Optional.
Open HTML report when complete

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Footer
{{ Fill Footer Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Thank you!

## RELATED LINKS

[https://github.com/Skatterbrainz/cmhealth/blob/master/docs/Out-CmHealthReport.md](https://github.com/Skatterbrainz/cmhealth/blob/master/docs/Out-CmHealthReport.md)

