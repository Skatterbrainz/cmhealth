<# 
.SYNOPSIS
Configure DB Maintenance Solution and Scheduling

.DESCRIPTION
Does the following magical stuff that will blow your mind:

* Creates a new database for Database Maintenance plan
* Ignores whiney complaints about being unsupported with the CM/SQL bundle licensing which I NEVER advised you to do anyway
* Installs Ola's solution
* Creates and schedules IndexOptimize task to optimize your indexes, or indices, I keep forgetting which is which

Go on, admit it, your mind has been blown. It's okay. Everyone needs their mind blown once a day.

.PARAMETER SQLInstance
Name of SQL host instance

.PARAMETER DBName
Name of new maintenance database

.EXAMPLE
.\Install-DbMaintenanceSolution.ps1 -SQLInstance "cm01.contoso.local" -DBName "dba"

.NOTES
8/27/2021
Original mind-blowing part by: Steve Thompson - if you see him, tell him you love him more than beer!
Doodling and silly comments by: David Stein - if you see him, tell him you love Steve Thompson more.
#>
[CmdletBinding()]
[OutputType([pscustomobject])]
param (
	[parameter(Mandatory=$False)][string]$SQLInstance = "localhost",
	[parameter(Mandatory=$False)][string]$Database = "DBA"
)

# Create a new database on the localhost named DBA
$param = @{
	SqlInstance = $SQLInstance
	Name = $Database
	Owner = "sa"
	RecoveryModel = "Simple"
}
New-DbaDatabase @param

# Install Ola Hallengrens Database Maintenance solution using the DBA database
$param = @{
	SqlInstance = $SQLInstance
	Database = $Database
	ReplaceExisting =-"InstallJobs"
}
Install-DbaMaintenanceSolution @param

# Create a new SQL Server Agent Job to schedule the custom Agent Task
$param = @{
	SqlInstance = $SQLInstance
	Job = "OptimizeIndexes"
	Owner = "sa"
	Description = "Ola Hallengren says you should Optimize your Indexes"
}
New-DbaAgentJob @param

$sqlcmd = "EXECUTE dbo.IndexOptimize
@Databases = 'USER_DATABASES',
@FragmentationLow = NULL,
@FragmentationMedium = 'INDEX_REORGANIZE,INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE',
@FragmentationHigh = 'INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE',
@FragmentationLevel1 = 10,
@FragmentationLevel2 = 40,
@UpdateStatistics = 'ALL',
@OnlyModifiedStatistics = 'Y',
@LogToTable = 'Y'"

# Create a new SQL Agent Task step with the optimal parameters for MEMCM
$param = @{
	SqlInstance = $SQLInstance
	Job = "OptimizeIndexes"
	StepName = "Step1"
	Database = $Database
	Command = $sqlcmd
}
New-DbaAgentJobStep @param

# Optionally, create a schedule to run the SQL Agent Tast once a week on Sunday @ 1:00AM
$param = @{
	SqlInstance = $SQLInstance
	Job = "OptimizeIndexes"
	Schedule = "RunWeekly"
	FrequencyType = "Weekly"
	FrequencyInterval = "Sunday"
	StartTime = "010000"
	Force = $True
}
New-DbaAgentSchedule @param
