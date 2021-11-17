---
external help file: cmhealth-help.xml
Module Name: cmhealth
online version: https://github.com/Skatterbrainz/cmhealth/blob/master/docs/Out-CmHealthReport.md
schema: 2.0.0
---

# Out-CmHealthReport

## SYNOPSIS
Export HTML healthcheck report

## SYNTAX

```
Out-CmHealthReport [-TestData] <Object> [[-ReportFile] <String>] [[-Status] <String>] [[-Title] <String>]
 [[-CssFile] <String>] [-Detailed] [-Show] [[-Footer] <String>] [[-LogFile] <String>] [<CommonParameters>]
```

## DESCRIPTION
Export HTML healthcheck report from results captured by Test-CmHealth

## EXAMPLES

### EXAMPLE 1
```
$testresult = Test-CmHealth -SiteCode P01 -Database CM_P01
$testresult | Out-CmHealthReport -Show
```

### EXAMPLE 2
```
Test-CmHealth -SiteCode P01 -Database CM_P01 | Out-CmHealthReport -Status Fail -Show
```

### EXAMPLE 3
```
Test-CmHealth -SiteCode P01 -Database CM_P01 | Out-CmHealthReport -Status Fail -Detailed -Show
```

## PARAMETERS

### -TestData
Health test data, returned from Test-CmHealth

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

### -ReportFile
{{ Fill ReportFile Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: "$($env:TEMP)\cmhealthreport-$(Get-Date -f 'yyyy-MM-dd').htm"
Accept pipeline input: False
Accept wildcard characters: False
```

### -Status
Filter results by status type: All, Fail, Pass, Warning, Error (default is All)

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: All
Accept pipeline input: False
Accept wildcard characters: False
```

### -Title
Title for report heading.
Default is "MECM"

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: MECM
Accept pipeline input: False
Accept wildcard characters: False
```

### -CssFile
Path to custom CSS stylesheet file.
If not provided, internal CSS is used by default.

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

### -Detailed
Show test output data in report

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

### -Show
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
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -LogFile
Path and name of Log file.
If Test-CmHealth has been invoked during the same PowerShell 
session, the LogFile will use the same filename and path.
The default path is $env:Temp

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 7
Default value: "$($env:TEMP)\cmhealth_$(Get-Date -f 'yyyy-MM-dd').log"
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

