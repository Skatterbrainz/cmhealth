<#
# credit: Chad Simmons:

# TASK: Get package source paths
# TASK: Get shares > root paths (drive\folder)
# TASK: Get Dedupe setting per volume

# TASK: Get DP servers

Get-DedupVolume | 
	Select-Object Volume, Enabled, MinimumFileAgeDays, MinimumFileSize, NoCompress, OptimizeInUseFiles, SavedSpace, SavingsRate, UnoptimizedSize, UsedSpace #-Volume $Drive

# TASK: Modify (below) to query dedupe settings

ForEach ($DPServer in $DPServers) {
	Invoke-Command -ComputerName $DPServer -ScriptBlock { 
		& { Import-Module Deduplication; $Drives = @((Get-WmiObject -Class Win32_LogicalDisk -Filter { DriveType = 3 }).DeviceID); ForEach ($Drive in $Drives) { If (Test-Path -Path "$Drive\SCCMContentLib") {Enable-DedupVolume $Drive; Set-DedupVolume –Volume $Drive -NoCompressionFileType @('7z','mp3','mp4','mkv','jpg','png','zpaq','bak','wim'); Start-DedupJob –Volume $Drive -Type Optimization -Preempt } } } 
	}
}
#>