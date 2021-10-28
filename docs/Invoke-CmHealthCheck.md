---
external help file: cmhealth-help.xml
Module Name: cmhealth
online version: https://github.com/Skatterbrainz/cmhealth/blob/master/docs/Get-CmHealthTests.md
schema: 2.0.0
---

# Invoke-CmHealthCheck

## SYNOPSIS
Auto-generate HTML reports for Test-CmHealth

## SYNTAX

```
Invoke-CmHealthCheck [-SiteCode] <String> [-SiteServer] <String> [-SQLInstance] <String> [-DBName] <String>
 [-ClientName] <String> [<CommonParameters>]
```

## DESCRIPTION
Generate an HTML report for both "summary" and "detailed" results by 
invoking Test-CmHealth and sending the output to two report files

## EXAMPLES

### EXAMPLE 1
```
Invoke-CmHealthCheck -SiteCode P01 -SiteServer cm01.contoso.local -SQLInstance cm01.contoso.local -DBName CM_P01 -ClientName Contoso
```

Generates "cmhealth_contoso_detailed_yyyyMMdd.htm" and "cmhealth_contoso_summary_yyyyMMdd.htm" both saved
under the current user Documents folder ($($env:USERPROFILE)\Documents)

## PARAMETERS

### -SiteCode
ConfigMgr site code

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

### -SiteServer
Name or FQDN of primary site server

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SQLInstance
Name or FQDN of SQL instance/host

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DBName
Name of ConfigMgr Database

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ClientName
Name of customer or owner of the primary site

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
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

## RELATED LINKS
