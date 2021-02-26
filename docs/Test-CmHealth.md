---
external help file: cmhealth-help.xml
Module Name: cmhealth
online version:
schema: 2.0.0
---

# Test-CmHealth

## SYNOPSIS
{{ Fill in the Synopsis }}

## SYNTAX

```
Test-CmHealth [-SiteCode] <String> [-Database] <String> [[-SiteServer] <String>] [[-SqlInstance] <String>]
 [[-TestingScope] <String>] [[-Remediate] <Boolean>] [[-Source] <String>] [[-Credential] <PSCredential>]
 [<CommonParameters>]
```

## DESCRIPTION
{{ Fill in the Description }}

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -Credential
{{ Fill Credential Description }}

```yaml
Type: PSCredential
Parameter Sets: (All)
Aliases:

Required: False
Position: 7
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Database
{{ Fill Database Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Remediate
{{ Fill Remediate Description }}

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SiteCode
{{ Fill SiteCode Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SiteServer
{{ Fill SiteServer Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Source
{{ Fill Source Description }}

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

### -SqlInstance
{{ Fill SqlInstance Description }}

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

### -TestingScope
{{ Fill TestingScope Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: All, AD, CM, Host, SQL, WSUS, Select, Previous

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
