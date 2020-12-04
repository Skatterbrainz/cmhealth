---
external help file: cmhealth-help.xml
Module Name: cmhealth
online version: https://github.com/Skatterbrainz/cmhealth/blob/master/docs/Test-CmHealth.md
schema: 2.0.0
---

# Test-CmHealth

## SYNOPSIS
Validate MECM/ConfigMgr site systems and configuration.

## SYNTAX

```
Test-CmHealth [[-SiteServer] <String>] [[-SqlInstance] <String>] [[-Database] <String>] [[-SiteCode] <String>]
 [[-TestingScope] <String>] [[-Remediate] <Boolean>] [[-Source] <String>] [-Initialize]
 [[-Credential] <PSCredential>] [<CommonParameters>]
```

## DESCRIPTION
Validate MECM/ConfigMgr site systems operational health status, and recommended configuration.

## EXAMPLES

### EXAMPLE 1
```
Test-CmHealth -Initialize
```

Generates a new cmhealth.json configuration file on the user desktop.
If the file exists, it will be replaced.

### EXAMPLE 2
```
Test-CmHealth
```

Runs all tests on the local machine using the current user credentials

### EXAMPLE 3
```
Test-CmHealth -SiteServer "CM01" -SqlInstance "CM01" -Database "CM_P01" -SiteCode "P01" -TestingScope "ALL"
```

Runs all tests

### EXAMPLE 4
```
Test-CmHealth -SiteServer "CM01" -SqlInstance "CM01" -Database "CM_P01" -SiteCode "P01" -TestingScope "Host"
```

Runs only the site server host tests

### EXAMPLE 5
```
Test-CmHealth -SiteServer "CM01" -SqlInstance "CM01" -Database "CM_P01" -SiteCode "P01" -TestingScope "Host" -Remediate -Credential $cred
```

Runs only the site server host tests and attempts to remediate identified deficiences using alternate user credentials

### EXAMPLE 6
```
Test-CmHealth -SiteServer "CM01" -SqlInstance "CM01" -Database "CM_P01" -SiteCode "P01" -TestingScope "Host" -Remediate -Source "\\server3\sources\ws2019\WinSxS"
```

Runs only the site server host tests and attempts to remediate identified deficiences with WinSXS source path provided

### EXAMPLE 7
```
$failed = Test-CmHealth | Where-Object Status -eq 'Fail'
```

Runs all tests and only returns those which failed

### EXAMPLE 8
```
Test-CmHealth | Select-Object TestName,Status,Message | Where-Object Status -eq 'Fail'
```

Display summary of failed tests

### EXAMPLE 9
```
$results = Test-CmHealth | Where-Object Status -eq 'Fail'; $results | Select TestData
```

Display test output from failed tests

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

### -Initialize
Creates or resets a default configuration file on the current user's Desktop named "cmhealth.json"

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

### -Credential
PS Credential object for authenticating under alternate context

```yaml
Type: PSCredential
Parameter Sets: (All)
Aliases:

Required: False
Position: 8
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

[https://github.com/Skatterbrainz/cmhealth/blob/master/docs/Test-CmHealth.md](https://github.com/Skatterbrainz/cmhealth/blob/master/docs/Test-CmHealth.md)

