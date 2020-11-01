# cmhealth

Test and validate various aspects of a MEM / Configuration Manager site server using packaged 
test rules.  The default parameters for each rule are stored in the cmhealth.json file under 
the "reserve" folder. This module is intended to be invoked on the Primary or CAS server using
an account which has full administrator rights to the host server, ConfigMgr, and SQL environments.

## Examples

### Install Module

```powershell
Install-Module cmhealth
```
(Note: this also installs modules dbatools, adsips, and carbon)

### Run all tests (default)

```powershell
$result = Test-CmHealth -SiteServer "CM01" -SqlInstance "CM01" -Database "CM_P01" -SiteCode "P01"
$result | Select-Object TestName,Status,Message
```

### Run only site server host tests

```powershell
$result = Test-CmHealth -SiteServer "CM01" -SqlInstance "CM01" -Database "CM_P01" -SiteCode "P01" -TestingScope "Host"
$result | Select-Object TestName,Status,Message
```

### Run selected tests only, from a grid-view menu

```powershell
$result = Test-CmHealth -SiteServer "CM01" -SqlInstance "CM01" -Database "CM_P01" -SiteCode "P01" -TestingScope "Select"
$result | Select-Object TestName,Status,Message
```

### Run all tests on site server and return only non-passing results

```powershell
Test-CmHealth -Database "CM_P01" -SiteCode "P01" -TestingScope All | where {$_.Status -ne 'PASS'}
```

## Issues, Requests, Bugs

* Please submit via the [Issues](https://github.com/Skatterbrainz/cmhealth/issues) link above

