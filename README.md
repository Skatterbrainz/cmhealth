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

## Installation

### Installing from PowerShell Gallery

```powershell
Install-Module cmhealth
```
Note: this also installs modules dbatools, adsips, and carbon.

### Manual or Offline Installation

For situations where the machine you wish to run cmhealth on does not have access to the Internet or the
PowerShell Gallery site.  For this situation, you will need to download the module .nupkg file, as well as the 
packages or the dependencies, and install them manually.

* Visit [PowerShell Gallery](https://www.powershellgallery.com) on a computer which can access the site
* Search for each of the following modules, and click the "Manual Download" tab
* Click the "Download the raw nupkg file" button to save the file locally
* Rename the file to add a .zip extension (makes it easier to open)
* Click the [Learn More](https://aka.ms/psgallery-manualdownload) link for instructions on how to extract and store the module files
* Modules:
  * [dbatools](https://www.powershellgallery.com/packages/dbatools/)
  * [carbon](https://www.powershellgallery.com/packages/carbon/)
  * [adsips](https://www.powershellgallery.com/packages/adsips/)
  * [cmhealth](https://www.powershellgallery.com/packages/cmhealth/)

## Usage / Examples

### First-Time Use

```powershell
Test-CmHealth -Initialize
```

This will create a file on your Desktop named "cmhealth.json".  This file contains the default values for
all of the tests to use for comparing with nominal or "best practices" settings. If you forget to do this 
the FIRST time, it will cause an error if you try to use any of the following examples below. You can copy 
an existing cmhealth.json from one machine or user desktop to another to save time.

### Show Detailed Help and Examples

```powershell
Get-Help Test-CmHealth -Full
```

### Run all tests (default options when running on the CM site server)

#### Important Notes 

* Test-CmHealth will return results to the console (pipeline).
* It is recommended that you capture the output in a variable to make it easier to inspect the results.
* The default site code is assumed to be "P01". Use the -SiteCode parameter to specify a different site code.
* The default SiteServer and SqlInstance parameter values are "localhost", which assumes running directly on a site system.
* The -Database and -SiteCode parameters are intentionally separate to allow for cases where the database is not using the default pattern "CM_$SiteCode".

### Specifying a Remote or Alternate Site System

```powershell
$result = Test-CmHealth -SiteServer "cmserver01.contoso.local" -SqlInstance "db1.contoso.local" -Database "CM_ABC" -SiteCode "ABC"
```

### Run only site server host tests

```powershell
Test-CmHealth -SiteServer "CM01" -SqlInstance "CM01" -Database "CM_P01" -SiteCode "ABC" -TestingScope Host
```
Note: The default -TestingScope is "ALL".

### Run selected tests only, from a grid-view menu

```powershell
Test-CmHealth -TestingScope Select
```

Seeing more details by using verbose output...

```powershell
Test-CmHealth -TestingScope Select -Verbose
```

### Run all tests on site server and return only failing results

```powershell
Test-CmHealth | where {$_.Status -ne 'PASS'}
```

### Run all tests on site server and return only warning results

```powershell
Test-CmHealth -TestingScope All | where {$_.Status -eq 'WARNING'}
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

## Issues, Requests, Bugs

* Please submit via the [Issues](https://github.com/Skatterbrainz/cmhealth/issues) link above

