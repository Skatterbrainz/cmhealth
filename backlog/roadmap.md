# Roadmap

### SQL Server Instance

Comp | Description | Function
--|--|--
SQL | CM DB Data files preallocated | TBD
SQL | CM DB Data files equal to # CPU cores  x 2 , but no greater than 8 | TBD
SQL | CM DB CM, WSUS, ReportingServices, ReportingServicesTempDB Log files equal to 1, preallocated, autogrowth | TBD
SQL | CM DB TempDB Data files equal to # CPU cores, but no greater than 4 | TBD
SQL | CM DB TempDB Log files equal to 1 | TBD
SQL | If bloated what are the largest SQL tables and their size | TBD
SQL | SSIS or other SQL features installed that are not used by ConfigMgr | TBD
SQL | SQL running on a static TCP port | TBD
SQL | SQL instance collation SQL_Latin1_General_CP1_CI_AS | Test-SqlDbCollation
SQL | SQL nested triggers enabled | TBD
SQL | SQL Server common language run time (CLR) enabled | TBD
SQL | SQL Server Service Broker enabled | TBD
SQL | SQL TRUSTWORTHY database property enabled | TBD
SQL | SQL Instant File Initialization enabled for all databases | TBD
SQL | Check SQL servers' local admin group for minimal membership | need to clarify
SQL | Support CM DB with custom naming schema (not just CM_<sitecode>) | need to clarify
SQL | Product Group guidance whitepaper from 2018 Oct https://gallery.technet.microsoft.com/Configuration-Manager-ba55428e | To Review
SQL | Microsoft PFE guidance whitepaper from 2020 Feb https://gallery.technet.microsoft.com/SQL-recommendations-for-ead4747f | To Review

### Configuration Manager

Comp | Description | Function
--|--|--
CM  | Check for content distributed to individual DPs... all should be distributed to a DP group | TBD
CM  | Drivers not in a Driver Package (and not in a WinPE folder?) | TBD
CM  | More than (X) Microsoft Updates (like 3000) | SUP sync or host OS?
CM  | More than (X) Microsoft Updates not required or installed (should be declined) | SUP sync or host OS?
CM  | Site and Component Status stuff | TBD
CM  | Number of Collections with incremental updates | TBD
CM  | Time for collections to update < incremental update time... analyzed over last 24 hours or all data in colleval.log | TBD
CM  | "busy" ConfigMgr logs with increased file size and history | TBD
CM  | Certs expired in last month or expiring in next month | TBD
CM  | Certs expired in last month or expiring in next month | TBD
CM  | Collections with no members (? and not flagged that they should have no members) | TBD
CM  | Collections set to never update | TBD
CM  | Application totals, active vs retired, active and deployed vs not-active and not-deployed and not-referenced by a TS | TBD
CM  | Packages same as Applications | TBD
CM  | TS not deployed and not a child TS | TBD
CM  | Drivers not in a driver package and not in a boot image | TBD
CM  | TS not using a custom boot image | (include child TS's??)
CM  | Customizations made to default boot images | TBD
CM  | DPs without Content Validation | TBD
CM  | Content not 100% replicated and > 24 hours old | TBD
CM  | Deployments with no activity in ~30 days | TBD
CM  | Deployments with more than x failures and x% failure rate | TBD
CM  | Client push install client account in domain admins group | TBD
CM  | Site install account not a limited rights user | TBD
CM  | Network access account not a limited rights user | TBD
CM  | domain join account in a TS that is a domain admin | TBD

#### Configuration Manager Software Update Point
Comp | Description | Function
--|--|--
CM SUP  | Check if common categories and products are enabled | TBD
CM SUP  | Sum of Windows 8.1 operating systems.  If = 0 recommend removing Windows 8.1 from SUP products | TBD
CM SUP  | Sum of Windows 8 operating systems.  If = 0 recommend removing Windows 8 from SUP products | TBD
CM SUP  | Sum of Windows 7 operating systems.  If = 0 recommend removing Windows 7 from SUP products | TBD
CM SUP  | Sum of Windows Vista operating systems.  If = 0 recommend removing Windows Vista from SUP products | TBD
CM SUP  | Sum of Windows XP operating systems.  If = 0 recommend removing Windows XP from SUP products | TBD
CM SUP  | Sum of Windows 2000 operating systems.  If = 0 recommend removing Windows 2000 from SUP products | TBD
CM SUP  | Sum of required and installed updates for each Windows version and architecture (32-bit, 64-bit, ARM64, Itanium).  If = 0 recommend declining all related updates in WSUS | TBD
CM SUP  | Sum of Office 2003 installs.  If = 0 recommend removing from SUP products | TBD
CM SUP  | Sum of Office 2007 installs.  If = 0 recommend removing from SUP products | TBD
CM SUP  | Sum of Office 2010 installs.  If = 0 recommend removing from SUP products | TBD
CM SUP  | Sum of Office 2013 installs.  If = 0 recommend removing from SUP products | TBD
CM SUP  | Sum of Office 2016 installs.  If = 0 recommend removing from SUP products | TBD
CM SUP  | Sum of required and installed updates for each Office version and architecture (32-bit, 64-bit).  If = 0 recommend declining all related updates in WSUS | TBD

### Primary Site Server host Operating System
Comp | Description | Function
--|--|--
OS  | Could check disk I/O for minimum thresholds | TBD
OS  | Check security roles to report extraneous members | TBD

### Remote SQL Site Server
Comp | Description | Function
--|--|--
OS  | Could check disk I/O for minimum thresholds | TBD
OS  | Check security roles to report extraneous members | TBD
