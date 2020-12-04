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

To add more tests, copy the "Test-Example.ps1" script from the "reserve" folder, to an appropriate name 
under the "Tests" folder. Then edit the parameters as follows:

* TestName = Same as filename (e.g. "Test-Something.ps1" enter "Test-Something")
* TestGroup = "configuration", or "operation" (type of condition)
* Description = whatever describes the test purpose

The -ScriptParams parameter is supplied by Test-CmHealth.

Follow the suggestions in the comments below that, then remove the comments if no longer needed.

## Custom Test Parameters

To add your own custom configuration mappings, use the cmhealth.json file, which is copied to your 
desktop via the -Initialize parameter.  Then use the ```Get-CmHealthDefaultValue``` function to 
retrieve it based on the group and keyname within the cmhealth.json file. Note that the variable $CmHealthConfig is defined by Test-CmHealth at runtime.

Example:

```powershell
Get-CmHealthDefaultValue -KeySet "sqlserver:MaxMemAllocationPercent" -DataSet $CmHealthConfig
```

## Examples

### Install Module

```powershell
Install-Module cmhealth
```
Note: this also installs modules dbatools, adsips, and carbon. So, if you are running this on 
a machine which cannot access the PowerShell Gallery, you will need to manually install these
other modules as well.

### Run all tests (default options when running on the CM site server)
(Note: default site code is assumed to be "P01", or use -SiteCode to override)

```powershell
$result = Test-CmHealth
$result | Select-Object TestName,Status,Message
```

### Run only site server host tests

```powershell
$result = Test-CmHealth -SiteServer "CM01" -SqlInstance "CM01" -Database "CM_P01" -SiteCode "P01" -TestingScope "Host"
$result | Select-Object TestName,Status,Message
```

### Run selected tests only, from a grid-view menu

```powershell
$result = Test-CmHealth -SiteCode "P01" -TestingScope "Select"
$result | Select-Object TestName,Status,Message
```

### Run all tests on site server and return only failing results

```powershell
$result = Test-CmHealth -SiteCode "P01" -TestingScope All | where {$_.Status -ne 'PASS'}
$result | Select-Object TestName,Status,Message | Where-Object Status -eq 'FAIL'
```

### Run all tests on site server and return only warning results

```powershell
$result = Test-CmHealth -Database "CM_P01" -SiteCode "P01" -TestingScope All | where {$_.Status -ne 'PASS'}
$result | Select-Object TestName,Status,Message | Where-Object Status -eq 'WARNING'
```

### It's also splattable, if that's even a real word

```powershell
$params = @{
	SiteServer = "sccm.contoso.local"
	SiteCode   = "P01"
	Database   = "CM_P01"
	TestingScope = "Sql"
	Credential = $mycredential
	Remediate  = $False
}
$result = Test-CmHealth @params
```

## Issues, Requests, Bugs

* Please submit via the [Issues](https://github.com/Skatterbrainz/cmhealth/issues) link above

