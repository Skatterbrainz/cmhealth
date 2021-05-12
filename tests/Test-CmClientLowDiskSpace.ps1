function Test-CmClientLowDiskSpace {
	[CmdletBinding()]
	param (
		[parameter()][string] $TestName = "Clients with Low Disk Space",
		[parameter()][string] $TestGroup = "operation",
		[parameter()][string] $Description = "Clients with low disk space on C`: drive",
		[parameter()][hashtable] $ScriptParams
	)
	try {
		$startTime = (Get-Date)
		#[int]$Setting = Get-CmHealthDefaultValue -KeySet "keygroup:keyname" -DataSet $CmHealthConfig
		[System.Collections.Generic.List[PSObject]]$tempdata = @() # for detailed test output to return if needed
		$stat   = "PASS" # do not change this
		$except = "WARNING" # or "FAIL"
		$msg    = "No issues found" # do not change this either
		$query = "select * from (
select cdr.Name, 
cdr.DeviceOS, 
cdr.ADSiteName,
cdr.LastLogonUser,
cdr.LastMPServerName,
ld.Name0 as Drive, 
ROUND((ld.Size0/1024),2) as SizeGB, 
ROUND((ld.FreeSpace0/1024),2) as FreeSpaceGB,
ROUND(((ld.Size0 - ld.FreeSpace0)/1024),2) as UsedGB,
ROUND(((ld.Size0 - ld.FreeSpace0) / CONVERT(decimal,ld.Size0)),2) as PctUsed
from v_CombinedDeviceResources cdr
inner join v_GS_LOGICAL_DISK ld on ld.ResourceID = cdr.MachineID
where ld.DeviceID0 = 'C:') as t1
where PctUsed > 0.8
order by Name"
		$res = Get-CmSqlQueryResult -Query $query -Params $ScriptParams
		if ($res.Count -gt 0) {
			$stat = $except
			$msg  = "$($res.Count) clients were found having more than 80% full on C drive"
			Write-Log -Message $msg
			$res | Foreach-Object {
                $tempdata.Add(
                    [pscustomobject]@{
                        Computer = $_.Name
                        OS       = $_.DeviceOS
                        ADSite   = $_.ADSiteName
                        LastUser = $_.LastLogonUser
                        LastMP   = $_.LastMPServerName
                        Drive    = $_.Drive
                        SizeMB   = $_.SizeMB
                        UsedMB   = $_.UsedMB
                        FreeMB   = $_.FreeSpaceMB
                        PctUsed  = [math]::Round(($_.PctUsed * 100),1)
                    }
                )
            }
		}
	}
	catch {
		$stat = 'ERROR'
		$msg = $_.Exception.Message -join ';'
	}
	finally {
		Write-Output $([pscustomobject]@{
			TestName    = $TestName
			TestGroup   = $TestGroup
			TestData    = $tempdata
			Description = $Description
			Status      = $stat
			Message     = $msg
			RunTime     = $(Get-RunTime -BaseTime $startTime)
			Credential  = $(if($ScriptParams.Credential){$($ScriptParams.Credential).UserName} else { $env:USERNAME })
		})
	}
}