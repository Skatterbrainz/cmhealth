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
SQL | SQL instanced collation SQL_Latin1_General_CP1_CI_AS | TBD
SQL | SQL nested triggers enabled | 
SQL | SQL Server common language run time (CLR) enabled | 
SQL | SQL Server Service Broker enabled | TBD
SQL | SQL TRUSTWORTHY database property enabled | 
SQL | SQL Instant File Initialization enabled for all databases | 
SQL | Check SQL servers' local admin group for minimal membership | need to clarify
SQL | Support CM DB with custom naming schema (not just CM_<sitecode>) | need to clarify
SQL | Product Group guidance whitepaper from 2018 Oct https://gallery.technet.microsoft.com/Configuration-Manager-ba55428e | To Review
SQL | Microsoft PFE guidance whitepaper from 2020 Feb https://gallery.technet.microsoft.com/SQL-recommendations-for-ead4747f | To Review

### Configuration Manager

Comp | Description | Function
--|--|--
CM  | Check for content distributed to individual DPs... all should be distributed to a DP group | 
CM  | Drivers not in a Driver Package (and not in a WinPE folder?) |
CM  | More than (X) Microsoft Updates (like 3000) | SUP sync or host OS?
CM  | More than (X) Microsoft Updates not required or installed (should be declined) | SUP sync or host OS?
CM  | Site and Component Status stuff |
CM  | Number of Collections with incremental updates |
CM  | Time for collections to update < incremental update time... analyzed over last 24 hours or all data in colleval.log |
CM  | "busy" ConfigMgr logs with increased file size and history |
CM  | Certs expired in last month or expiring in next month |
CM  | Certs expired in last month or expiring in next month |
CM  | Collections with no members (? and not flagged that they should have no members) |
CM  | Collections set to never update |
CM  | Application totals, active vs retired, active and deployed vs not-active and not-deployed and not-referenced by a TS |
CM  | Packages same as Applications |
CM  | TS not deployed and not a child TS |
CM  | Drivers not in a driver package and not in a boot image |
CM  | TS not using a custom boot image | (include child TS's??)
CM  | Customizations made to default boot images |
CM  | DPs without Content Validation |
CM  | Content not 100% replicated and > 24 hours old |
CM  | Deployments with no activity in ~30 days |
CM  | Deployments with more than x failures and x% failure rate |
CM  | Client push install client account in domain admins group |
CM  | Site install account not a limited rights user |
CM  | Network access account not a limited rights user |
CM  | domain join account in a TS that is a domain admin |

#### Configuration Manager Software Update Point
Comp | Description | Function
--|--|--
CM SUP  | Check if common categories and products are enabled |
CM SUP  | Sum of Windows 8.1 operating systems.  If = 0 recommend removing Windows 8.1 from SUP products  | 
CM SUP  | Sum of Windows 8 operating systems.  If = 0 recommend removing Windows 8 from SUP products  | 
CM SUP  | Sum of Windows 7 operating systems.  If = 0 recommend removing Windows 7 from SUP products  | 
CM SUP  | Sum of Windows Vista operating systems.  If = 0 recommend removing Windows Vista from SUP products  | 
CM SUP  | Sum of Windows XP operating systems.  If = 0 recommend removing Windows XP from SUP products  | 
CM SUP  | Sum of Windows 2000 operating systems.  If = 0 recommend removing Windows 2000 from SUP products  | 
CM SUP  | Sum of required and installed updates for each Windows version and architecture (32-bit, 64-bit, ARM64, Itanium).  If = 0 recommend declining all related updates in WSUS  | 
CM SUP  | Sum of Office 2003 installs.  If = 0 recommend removing from SUP products  | 
CM SUP  | Sum of Office 2007 installs.  If = 0 recommend removing from SUP products  | 
CM SUP  | Sum of Office 2010 installs.  If = 0 recommend removing from SUP products  | 
CM SUP  | Sum of Office 2013 installs.  If = 0 recommend removing from SUP products  | 
CM SUP  | Sum of Office 2016 installs.  If = 0 recommend removing from SUP products  | 
CM SUP  | Sum of required and installed updates for each Office version and architecture (32-bit, 64-bit).  If = 0 recommend declining all related updates in WSUS  | 

### Primary Site Server host Operating System
Comp | Description | Function
--|--|--
OS  | Could check disk I/O for minimum thresholds |
OS  | Check security roles to report extraneous members |

### Remote SQL Site Server
Comp | Description | Function
--|--|--
OS  | Could check disk I/O for minimum thresholds |
OS  | Check security roles to report extraneous members |