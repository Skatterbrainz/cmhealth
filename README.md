# cmhealth

## Checklist

Comp | Description | Function
--|--|--
SQL | Data files stored on a NTFS disk w/64K clusters or ReFS disk w/ => 64k clusters | 
SQL | Memory allocation (local/remote) | Test-SqlServerMemory.ps1
SQL | CM DB Data files preallocated | 
SQL | CM DB Data files set with autogrowth at =>10% or =>256MB per file | Test-SqlCmDbFileGrowth.ps1
SQL | CM DB same above for TempDB, WSUS, SSRS, etc | Test-SqlCmDbFileGrowth.ps1
SQL | CM DB Data files equal to # CPU cores  x 2 , but no greater than 8 | 
SQL | CM DB CM, WSUS, ReportingServices, ReportingServicesTempDB Log files equal to 1, preallocated, autogrowth | 
SQL | CM DB TempDB Data files equal to # CPU cores, but no greater than 4 | 
SQL | CM DB TempDB Log files equal to 1 | 
SQL | CM DB Data files index fragmentation percent | Test-SqlIndexFragmentation.ps1
SQL | CM DB Database total size within x% of # of clients * 5MB + 5GB (make sure it isn't bloated) | Test-CmDbSize.ps1
SQL | If bloated what are the larges SQL tables and their size | 
SQL | SSIS or other SQL features installed that are not used by ConfigMgr | 
SQL | SQL running on a static TCP port | 
SQL | Databases on the CM SQL instance that are not supported by usage rights (if SQL is Standard) | Test-SqlDbDedicated.ps1
SQL | is the SQL instanced collation SQL_Latin1_General_CP1_CI_AS | 
SQL | are SQL nested triggers enabled | 
SQL | is SQL Server common language run time (CLR) enabled | 
SQL | is SQL Server Service Broker enabled | 
SQL | is SQL TRUSTWORTHY database property enabled | 
SQL | is the SQL Server service account the local SYSTEM or a low rights domain user registered SPN | 
SQL | does the SQL Instance admins (sysadmins) include the Primary Site server's computer account | 
SQL | is there at least 10GB free on the SQL CM db's disk drive(s) | 
SQL | is SQL Instant File Initialization enabled for all databases | 
SQL | latest supported SP installed | 
SQL | latest CU installed | 
SQL | Service Accounts have correct privilegs | Test-ServiceAccounts.ps1
SQL | check SQL servers' local admin group for minimal membership |
SQL | support CM db with custom naming schema (not just CM_<sitecode>) |
CM | check for duplicate Boundaries and Boundaries not in a Group |
CM | check for content distributed to individual DPs... all should be distributed to a DP group |
CM | drivers not in a Driver Package (and not in a WinPE folder?) |
CM | More than (X) Microsoft Updates (like 3000) | SUP sync or host OS?
CM | More than (X) Microsoft Updates not required or installed (should be declined) | SUP sync or host OS?
CM | Site and Component Status stuff |
CM | # Collections with incremental updates |
CM | time for collections to update < incremental update time... analyzed over last 24 hours or all data in colleval.log |
CM | "busy" ConfigMgr logs with increased file size and history |
CM | MaxMIFsize for hardware inventory < max of 50 MB |
CM | Certs expired in last month or expiring in next month |
CM | Certs expired in last month or expiring in next month |
CM | Collections with no members (? and not flagged that they should have no members) |
CM | Collections set to never update |
CM | Application totals, active vs retired, active and deployed vs not.  active and not deployed and not referenced by a TS |
CM | Packages same as Applications |
CM | TS not deployed and not a child TS |
CM | Drivers not in a driver package and not in a boot image |
CM | TS not using a custom boot image |
CM | Customizations made to default boot images |
CM | DPs not in a DP group |
CM | DPs without Content Validation |
CM | Content not 100% replicated and > 24 hours old |
CM | Deployments with no activity in ~30 days |
CM | Deployments with more than x failures and x% failure rate |
CM | Client push install client account in domain admins group |
CM | Site install account not a limited rights user |
CM | Network access account not a limited rights user |
CM | domain join account in a TS that is a domain admin |
OS | Missing Windows Updates | Test-WindowsUpdates.ps1
OS | NO_SMS_ON_DRIVE.sms on all drives except (list of drives) | Test-NoSmsOnDriveFile.ps1
OS | Free disk space on all drives without NO_SMS_ON_DRIVE.sms > 10 GB |
OS | Could check disk I/O for minimum thresholds |
OS | check security roles to report extraneous members |
