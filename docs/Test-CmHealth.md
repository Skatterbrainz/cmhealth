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
Test-CmHealth [-SiteCode] <String> [-Database] <String> [[-SiteServer] <String>] [[-SqlInstance] <String>]
 [[-TestingScope] <String>] [[-ConfigFile] <String>] [[-Credential] <PSCredential>] [[-LogFile] <String>]
 [-NoVersionCheck] [-AllServers] [<CommonParameters>]
```

## DESCRIPTION
Validate MECM/ConfigMgr site systems operational health status, and recommended configuration.

## EXAMPLES

### EXAMPLE 1
```
Test-CmHealth -SiteCode "P01" -Database "CM_P01"
```

Runs all tests on the local machine

### EXAMPLE 2
```
Test-CmHealth -SiteCode "P01" -Database "CM_P01" -AllServers
```

Runs all tests on all site systems

### EXAMPLE 3
```
Test-CmHealth -SiteCode "P01" -Database "CM_P01" -SiteServer "CM01" -SqlInstance "CM01" -TestingScope "ALL"
```

Runs all tests

### EXAMPLE 4
```
Test-CmHealth -SiteCode "P01" -Database "CM_P01" -SiteServer "CM01" -SqlInstance "CM01" -TestingScope "Host"
```

Runs only the site server host tests

### EXAMPLE 5
```
Test-CmHealth -SiteCode "P01" -Database "CM_P01" -SiteServer "CM01" -SqlInstance "CM01" -TestingScope "Host" -Remediate -Credential $cred
```

Runs only the site server host tests and attempts to remediate identified deficiences using alternate user credentials

### EXAMPLE 6
```
Test-CmHealth -SiteCode "P01" -Database "CM_P01" -SiteServer "CM01" -SqlInstance "CM01" -TestingScope "Host" -Remediate -Source "\\server3\sources\ws2019\WinSxS"
```

Runs only the site server host tests and attempts to remediate identified deficiences with WinSXS source path provided

### EXAMPLE 7
```
$failed = Test-CmHealth -SiteCode "P01" -Database "CM_P01" | Where-Object Status -eq 'Fail'
```

Runs all tests and only returns those which failed

### EXAMPLE 8
```
Test-CmHealth -SiteCode "P01" -Database "CM_P01" | Select-Object TestName,Status,Message | Where-Object Status -eq 'Fail'
```

Display summary of failed tests

### EXAMPLE 9
```
$results = Test-CmHealth -SiteCode "P01" -Database "CM_P01" | Where-Object Status -eq 'Fail'; $results | Select TestData
```

Display test output from failed tests

### EXAMPLE 10
```
$results = Test-CmHealth -SiteCode "P01" -Database "CM_P01" -TestScope Previous
```

Run the same set of tests as the previous session (each run saves list of test names)

## PARAMETERS

### -SiteCode
ConfigMgr 3-character alphanumeric site code.

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

### -Database
Name of site SQL database.

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

### -SiteServer
NetBIOS or FQDN of site server (primary, CAS, secondary).
Default is localhost

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: "$((Get-WmiObject win32_computersystem).DNSHostName+"."+$(Get-WmiObject win32_computersystem).Domain)"
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
Position: 4
Default value: "$((Get-WmiObject win32_computersystem).DNSHostName+"."+$(Get-WmiObject win32_computersystem).Domain)"
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

### -ConfigFile
Path to cmhealth.json (create or import).
If not found, it will attempt to create a new
one in the specified path. 
The default path is the user TEMP folder.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: "$($env:TEMP)\cmhealth.json"
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
Position: 7
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -LogFile
Path and name of log file.
Default is $env:TEMP\cmhealth_yyyy-mm-dd.log

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 8
Default value: "$($env:TEMP)\cmhealth_$(Get-Date -f 'yyyy-MM-dd').log"
Accept pipeline input: False
Accept wildcard characters: False
```

### -NoVersionCheck
Skip checking for newer module version (default is to attempt a version check)

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

### -AllServers
Run tests on all site systems within the current ConfigMgr site database

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
Thank you!

## RELATED LINKS

[https://github.com/Skatterbrainz/cmhealth/blob/master/docs/Test-CmHealth.md](https://github.com/Skatterbrainz/cmhealth/blob/master/docs/Test-CmHealth.md)

