# cmhealth

Test and validate various aspects of a MEM / Configuration Manager site server using packaged 
"test" rules.  The default parameters for each rule are stored in the cmhealth.json file under 
the "reserve" folder. This module is intended to be invoked on the Primary or CAS server using
an account which has full administrator rights to the host server, ConfigMgr, and SQL environments.

The main purpose of this module is to generate pipeline output for subsequent action/automation, 
not to generate documentation. However, you can easily send the output to HTML reports using 
```Out-CmHealthReport``` or by using ```Invoke-CmHealthCheck``` functions.

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
  * [cmhealth](https://www.powershellgallery.com/packages/cmhealth/)
  * [psWindowsUpdate](https://www.powershellgallery.com/packages/pswindowsupdate/)
* (adsips dependency was removed as of cmhealth 0.3.5)

## Usage / Examples

### First-Time Use

The first time you invoke Test-CmHealth, it will create a file on your Desktop named "cmhealth.json".
This file contains the default values for all of the tests to use for comparing with nominal or "best practices". 

**Not happy with the baseline values? Not a problem!** Simply edit the cmhealth.json file on your 
desktop, and adjust to your preferences. Thi

You can copy an existing cmhealth.json from one machine or user desktop to another to save time.

### Keep Up to Date

Use the ```Update-Module``` cmdlet to update the cmhealth module, as shown below:

```powershell
Update-Module cmhealth
```

Check and Update dependencies. This will keep the other modules up to date, such as dbatools and carbon.

```powershell
Test-CmHealthDependencies -Update
```

### Show Detailed Help and Examples

```powershell
Get-Help Test-CmHealth -Full
Get-Help Invoke-CmHealthReport -Full
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
$result = Test-CmHealth -SiteCode "ABC" -Database "CM_P01" -SiteServer "cmserver01.contoso.local" -SqlInstance "db1.contoso.local"
```

### Run specific types of tests by TestingScope name

```powershell
Test-CmHealth -SiteCode "ABC" -Database "CM_P01" -SiteServer "CM01" -SqlInstance "CM01" -TestingScope Host
```
Note: This will run all "Host" tests. The default -TestingScope is "ALL".

### Run selected tests by selecting in a GridView menu

```powershell
Test-CmHealth -SiteCode "ABC" -Database "CM_P01" -TestingScope Select
```

Seeing more details by using verbose output...

```powershell
Test-CmHealth -SiteCode "ABC" -Database "CM_P01" -TestingScope Select -Verbose
```

### Run all tests on site server and return only failing results

```powershell
Test-CmHealth -SiteCode "ABC" -Database "CM_P01" | where {$_.Status -ne 'PASS'}
```

### Run all tests on site server and return only warning results

```powershell
Test-CmHealth -SiteCode "ABC" -Database "CM_P01" -TestingScope All | where {$_.Status -eq 'WARNING'}
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

## Generate an HTML Report

You can save the output to HTML several ways. One is is to use the ```Invoke-CmHealthCheck``` function, which will
generate both "detailed" and "summary" HTML reports.  Another is to capture the output from 
```Test-CmHealth``` to a variable and then pipe that to ```Out-CmHealthReport``` to export an
HTML report. This option allows you to inspect the results from the variable contents, before
you send the output to a report file.

For more information use ```Get-Help Out-CmHealthReport``` and ```Get-Help Invoke-CmHealthCheck```

### Examples

Save non-passing results to an HTML report

```
$result = Test-CmHealth -SiteCode P01 -Databsae CM_P01
$nonpassing = $result | Where-Object {$_.Status -ne 'Pass'}
$nonpassing | Out-CMHealthReport -Show
```

## Adding Your Own Tests

The tests provided with the basic installation can be viewed [here](https://github.com/Skatterbrainz/cmhealth/tree/master/tests).

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

