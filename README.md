# cmhealth

Test and validate various aspects of a MEM / Configuration Manager site server using packaged 
test rules.  The default parameters for each rule are stored in the cmhealth.json file under 
the "reserve" folder. This module is intended to be invoked on the Primary or CAS server using
an account which has full administrator rights to the host server, ConfigMgr, and SQL environments.

The purpose of this module is not to generate documentation, although you can easily send the output
to any document type you desire (or database, REST API, Log Analytics, carrier pidgeon, or two cans 
connected with a string). The purpose of this is to output the test results to the PowerShell pipeline
to enable automation to be triggered. Send an email, output to a log/database/whatever, invoke an 
automation job (Azure Automation, Azure Function, Power Automate, etc.).

You can invoke this module from an Azure Automation runbook against on-prem servers using a hybrid
worker. If you want more information on this, let me know.

## Adding Your Own Tests

To add more tests, copy the "Test-Example.ps1" script to an appropriate name under the "Tests" folder.
Then edit the parameters as follows:

* TestName = Same as filename (e.g. "Test-Something.ps1" enter "Test-Something")
* TestGroup = "configuration", or "operation" (type of condition)
* Description = whatever describes the test purpose

Follow the suggestions in the comments below that, then remove the comments if no longer needed.

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

