---
external help file: cmhealth-help.xml
Module Name: cmhealth
online version: https://github.com/Skatterbrainz/cmhealth
schema: 2.0.0
---

# Test-CmHealth

## SYNOPSIS
Validate MECM/ConfigMgr site systems and configuration.

## SYNTAX

```
Test-CmHealth [[-SiteServer] <String>] [[-SqlInstance] <String>] [[-Database] <String>] [[-SiteCode] <String>]
 [[-TestingScope] <String>] [[-Remediate] <Boolean>] [[-Source] <String>] [[-DaysBack] <Int32>]
 [[-Credential] <PSCredential>] [<CommonParameters>]
```

## DESCRIPTION
Validate MECM/ConfigMgr site systems and configuration.

## EXAMPLES

### EXAMPLE 1
```
Test-CmHealth -SiteServer "CM01" -SqlInstance "CM01" -Database "CM_P01" -SiteCode "P01" -TestingScope "ALL"
```

Runs all tests

### EXAMPLE 2
```
Test-CmHealth -SiteServer "CM01" -SqlInstance "CM01" -Database "CM_P01" -SiteCode "P01" -TestingScope "Host"
```

Runs only the site server host tests

### EXAMPLE 3
```
Test-CmHealth -SiteServer "CM01" -SqlInstance "CM01" -Database "CM_P01" -SiteCode "P01" -TestingScope "Host" -Remediate -Credential $cred
```

Runs only the site server host tests and attempts to remediate identified deficiences using alternate user credentials

### EXAMPLE 4
```
Test-CmHealth -SiteServer "CM01" -SqlInstance "CM01" -Database "CM_P01" -SiteCode "P01" -TestingScope "Host" -Remediate -Source "\\server3\sources\ws2019\WinSxS"
```

Runs only the site server host tests and attempts to remediate identified deficiences with WinSXS source path provided

## PARAMETERS

### -SiteServer
NetBIOS or FQDN of site server (primary, CAS, secondary).
Default is localhost

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: Localhost
Accept pipeline input: False
Accept wildcard characters: False
```

### -SqlInstance
NetBIOS or FQDN of site database SQL instance.
Default is localhost

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: Localhost
Accept pipeline input: False
Accept wildcard characters: False
```

### -Database
Name of site database.
Default is "CM_P01"

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: CM_P01
Accept pipeline input: False
Accept wildcard characters: False
```

### -SiteCode
ConfigMgr site code.
Default is "P01"

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TestingScope
Scope of tests to execute: All (default), Host, AD, SQL, CM, WSUS, Select
The Select option displays a gridview to select the individual tests to perform

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: All
Accept pipeline input: False
Accept wildcard characters: False
```

### -Remediate
Attempt remediation when possible

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Source
Alternate source path for WinSXS referencing.
Used only for Test-HostServerFeatures
Default is C:\Windows\WinSxS

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 7
Default value: C:\windows\winsxs
Accept pipeline input: False
Accept wildcard characters: False
```

### -DaysBack
Number of days to go back for checking status messages, errors, warnings, etc.
Default is 7

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 8
Default value: 7
Accept pipeline input: False
Accept wildcard characters: False
```

### -Credential
PS Credential object for authenticating under alternate context

```yaml
Type: PSCredential
Parameter Sets: (All)
Aliases:

Required: False
Position: 9
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

[https://github.com/Skatterbrainz/cmhealth](https://github.com/Skatterbrainz/cmhealth)

