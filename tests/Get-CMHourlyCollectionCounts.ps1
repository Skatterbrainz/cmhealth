<#
.NOTES
	Source: https://model-technology.com/blog/troubleshooting-slow-collection-evaluation-in-sccm-2012-part-3-aka-how-to-identify-collection-update-loitering/
	Author: Steve Bowman
	Adapted by: David Stein
#>
Function Get-CMHourlyCollectionCounts {
	[CmdletBinding()]
	param (
		[parameter()][string] $CMDatabaseServer = "localhost",
		[parameter()][ValidateNotNullOrEmpty()][string] $CMDatabaseName = "",
		[parameter()][ValidateLength(3,3)][string] $CMSiteCode = ""
	)
	try {
		$OldLocation = $(Get-Location).Path

		if ([string]::IsNullOrEmpty($CMDatabaseName)) { throw "Database Name was not provided" }
		if ([string]::IsNullOrEmpty($CMSiteCode)) { throw "SiteCode was not provided" }
		
		#region Set up environment
		$StartDate = Get-Date
		$NumDays = 8
		$EndDate = $StartDate.AddDays($NumDays)
		$GridInterval = 1
		#Make Connection to SCCM 2012
		Write-Verbose "Making connection to ConfigMgr site"
	
		$cmModule = Join-Path $(Split-Path $env:SMS_ADMIN_UI_PATH) "ConfigurationManager.psd1"
		if (-not(Test-Path $cmModule)) { throw "CM PowerShell module not found" }
		#Modules
		Import-Module $cmModule -Force
		
		#Enter SCCM PSProvider
		Set-Location "$($CMSiteCode):\"
		#endregion
		
		#region Build Schedule Results Grid
		$Results = @{"$($StartDate.Date.ToString("MM-dd-yyyy")) $($StartDate.TimeofDay.ToString("hh")):00" = 0 }
		$TestDate = $StartDate
	
		Do {
			$TestDate = $TestDate.AddHours($GridInterval)
			$Results.Add("$($TestDate.Date.ToString("MM-dd-yyyy")) $($TestDate.TimeOfDay.ToSTring("hh")):00", 0)
			# Write-Host "$($TestDate.Date.ToString("MM-dd-yyyy")) $($TestDate.TimeOfDay.ToSTring("hh")):00"
			$Output = $Output + $Item
		
		} while ($TestDate -le $EndDate)
		#endregion
		
		#region Build Incremental Results Grid
		$IncResults = @{"$($StartDate.Date.ToString("MM-dd-yyyy")) $($StartDate.TimeofDay.ToString("hh")):00" = 0 }
		$TestDate = $StartDate
	
		Do {
			$TestDate = $TestDate.AddHours($GridInterval)
			$IncResults.Add("$($TestDate.Date.ToString("MM-dd-yyyy")) $($TestDate.TimeOfDay.ToSTring("hh")):00", 0)
			# Write-Host "$($TestDate.Date.ToString("MM-dd-yyyy")) $($TestDate.TimeOfDay.ToSTring("hh")):00"
			$Output = $Output + $Item
		
		} while ($TestDate -le $EndDate)
		#endregion
	
		#region Process All Collections
		$Collections = Invoke-Sqlcmd -ServerInstance $CMDatabaseServer -Database $CMDatabaseName -Query "Select SiteID, CollectionName, Schedule, EvaluationStartTime, RefreshType from v_Collections"
		
		$IncrInt = Invoke-Sqlcmd -ServerInstance $CMDatabaseServer -Database $CMDatabaseName -Query "Select Name, Value3 as Value from vSMS_SC_Component_Properties where Name = 'Incremental Interval'"
		
		Foreach ($Collection in $Collections) {
		
			Write-Verbose "Processing: $($Collection.SiteID) - $($Collection.CollectionName)"
			#Process Scheduled Collections
			If ($Collection.RefreshType -eq 2 -or $Collection.RefreshType -eq 6) {
		
				$Sched = Convert-CMSchedule -ScheduleString $Collection.Schedule
		
				#Process Monthly by Date
				if ($Sched.MonthDay -gt 0 -and $Sched.ForNumberOfMonths -gt 0) {
					##Monthly by Date Schedule
					$LastEval = $Collection.EvaluationStartTime
		
					If ($LastEval.Day -eq $Sched.MonthDay -and $LastEval -ge $StartDate -and $LastEval -le $EndDate) {
		
						If ($Results.ContainsKey("$($LastEval.Date.ToString("MM-dd-yyyy")) $($LastEval.TimeOfDay.ToSTring("hh")):00")) {
							$Count = $Results.Get_Item("$($LastEval.Date.ToString("MM-dd-yyyy")) $($LastEval.TimeOfDay.ToSTring("hh")):00")
							$Results.Set_Item("$($LastEval.Date.ToString("MM-dd-yyyy")) $($LastEval.TimeOfDay.ToSTring("hh")):00", ($Count + 1))
						}
		
					}
					else {
						$NextMonth = Get-Date -Date "$($LastEval.Month + 1)/1/$($LastEval.Year) $($Sched.StartTime.TimeOfDay.ToString())"
		
						if ($NextMonth -ge $StartDate -and $NextMonth -le $EndDate) {
							If ($Results.ContainsKey("$($NextMonth.Date.ToString("MM-dd-yyyy")) $($NextMonth.TimeOfDay.ToSTring("hh")):00")) {
								$Count = $Results.Get_Item("$($NextMonth.Date.ToString("MM-dd-yyyy")) $($NextMonth.TimeOfDay.ToSTring("hh")):00")
								$Results.Set_Item("$($NextMonth.Date.ToString("MM-dd-yyyy")) $($NextMonth.TimeOfDay.ToSTring("hh")):00", ($Count + 1))
							}
						}
					}
				}
		
				$LastEval = $Collection.EvaluationStartTime
				If ($Sched.DaySpan -gt 0 -or $Sched.HourSpan -gt 0 -or $Sched.MinuteSpan -gt 0) {
		
					Do {
						$LastEval = $LastEval.AddDays($Sched.DaySpan)
						$LastEval = $LastEval.AddHours($Sched.HourSpan)
						$LastEval = $LastEval.AddMinutes($Sched.MinuteSpan)
						If ($Sched.ForNumberOfWeeks -gt 0) {
							$Days = (($Sched.Day + 1) * $Sched.ForNumberOfWeeks)
							$LastEval = $LastEval.AddDays($Days)
						}
		
						If ($Sched.ForNumberOfMonths -gt 0) {
							If ($LastEval.Day -ne $Sched.MonthDay) {
								$LastEval = $LastEval.AddDays(1)
							}
							else {
								Continue
							}
						}
						If ($LastEval -ge $StartDate -and $LastEval -le $EndDate) {
		
							If ($Results.ContainsKey("$($LastEval.Date.ToString("MM-dd-yyyy")) $($LastEval.TimeOfDay.ToSTring("hh")):00")) {
								$Count = $Results.Get_Item("$($LastEval.Date.ToString("MM-dd-yyyy")) $($LastEval.TimeOfDay.ToSTring("hh")):00")
								$Results.Set_Item("$($LastEval.Date.ToString("MM-dd-yyyy")) $($LastEval.TimeOfDay.ToSTring("hh")):00", ($Count + 1))
							}
		
						}
		
					} while ($LastEval -le $EndDate)
		
				} #End Processing Interval Schedules
		
			} #End Processing Schedules
		
			#Process Incremental Schedules
			If ($Collection.RefreshType -eq 4 -or $Collection.RefreshType -eq 6) {
				$LastEval = $Collection.EvaluationStartTime
				Do {
					$LastEval = $LastEval.AddMinutes($IncrInt.Value)
		
					If ($LastEval -ge $StartDate -and $LastEval -le $EndDate) {
		
						If ($IncResults.ContainsKey("$($LastEval.Date.ToString("MM-dd-yyyy")) $($LastEval.TimeOfDay.ToSTring("hh")):00")) {
							$Count = $IncResults.Get_Item("$($LastEval.Date.ToString("MM-dd-yyyy")) $($LastEval.TimeOfDay.ToSTring("hh")):00")
							$IncResults.Set_Item("$($LastEval.Date.ToString("MM-dd-yyyy")) $($LastEval.TimeOfDay.ToSTring("hh")):00", ($Count + 1))
						}
		
					}
				} while ($LastEval -le $EndDate)
		
			} #End Processing Incremental Schedules
		
		}
		$Output = @()
	
		Foreach ($Result in $Results) {
			$FailedPkg = New-Object -TypeName PSObject
			Add-Member -InputObject $FailedPkg -MemberType NoteProperty -Name PackageID -Value $Failure.PackageID
		}
		
		$Results.GetEnumerator() | Sort-Object -Property Name | Select-Object Name, Value | Export-Csv -Path c:\Windows\Temp\SchedResults.csv -NoTypeInformation
		$IncResults.GetEnumerator() | Sort-Object -Property Name | Select-Object Name, Value | Export-Csv -Path c:\Windows\Temp\IncSchedResults.csv -NoTypeInformation
	}
	catch {
		Write-Error $_.Exception.Message
	}
	finally {
		Set-Location $OldLocation
	}
}