---
external help file: cmhealth-help.xml
Module Name: cmhealth
online version: https://github.com/Skatterbrainz/cmhealth/blob/master/docs/Out-HealthReport.md
schema: 2.0.0
---

# Out-HealthReport

## SYNOPSIS
Export HTML report

## SYNTAX

```
Out-HealthReport [-TestData] <Object> [[-Path] <String>] [[-Status] <String>] [[-Title] <String>]
 [[-CssFile] <String>] [-Detailed] [-Show] [<CommonParameters>]
```

## DESCRIPTION
Export HTML health test report

## EXAMPLES

### EXAMPLE 1
```
$testresult = Test-CmHealth -SiteCode P01 -Database CM_P01
$testresult | Out-HealthReport -Show
```

### EXAMPLE 2
```
Test-CmHealth -SiteCode P01 -Database CM_P01 | Out-HealthReport -Status Fail -Show
```

### EXAMPLE 3
```
Test-CmHealth -SiteCode P01 -Database CM_P01 | Out-HealthReport -Status Fail -Detailed -Show
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

### -Path
HTML file path

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: "$($env:TEMP)\healthreport.htm"
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
{{ Fill Title Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: ConfigMgr Site
Accept pipeline input: False
Accept wildcard characters: False
```

### -CssFile
{{ Fill CssFile Description }}

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Released with 0.2.24

## RELATED LINKS

[https://github.com/Skatterbrainz/cmhealth/blob/master/docs/Out-HealthReport.md](https://github.com/Skatterbrainz/cmhealth/blob/master/docs/Out-HealthReport.md)

