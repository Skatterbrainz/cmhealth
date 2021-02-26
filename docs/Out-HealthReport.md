---
external help file: cmhealth-help.xml
Module Name: cmhealth
online version:
schema: 2.0.0
---

# Out-HealthReport

## SYNOPSIS
Export HTML report

## SYNTAX

```
Out-HealthReport [-TestData] <Object> [[-Path] <String>] [[-Status] <String>] [-Show] [<CommonParameters>]
```

## DESCRIPTION
Export HTML health test report

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

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
Default value: "$($env:USERPROFILE)\Desktop\healthreport.htm"
Accept pipeline input: False
Accept wildcard characters: False
```

### -Status
{{ Fill Status Description }}

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

## RELATED LINKS
