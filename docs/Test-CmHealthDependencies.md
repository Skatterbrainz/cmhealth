---
external help file: cmhealth-help.xml
Module Name: cmhealth
online version: https://github.com/Skatterbrainz/cmhealth/blob/master/docs/Test-CmHealthDependencies.md
schema: 2.0.0
---

# Test-CmHealthDependencies

## SYNOPSIS
Check (and update) dependent PowerShell modules

## SYNTAX

```
Test-CmHealthDependencies [<CommonParameters>]
```

## DESCRIPTION
Check current install versions of dependent PowerShell modules against
PowerShell Gallery and update them if desired

## EXAMPLES

### EXAMPLE 1
```
Test-CmHealthDependencies
Returns status of installed modules which are used by CMHealth
```

### EXAMPLE 2
```
Test-CmHealthDependencies -Update
Updates installed modules used by CMHealth if they are older than published on PS Galler
```

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

[https://github.com/Skatterbrainz/cmhealth/blob/master/docs/Test-CmHealthDependencies.md](https://github.com/Skatterbrainz/cmhealth/blob/master/docs/Test-CmHealthDependencies.md)

