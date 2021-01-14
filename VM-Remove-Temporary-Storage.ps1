#Remove pagesys
$CurrentPageFile = Get-WmiObject -Query 'select * from Win32_PageFileSetting'
$CurrentPageFile.delete()
Set-WMIInstance -Class Win32_PageFileSetting -Arguments @{name='c:\pagefile.sys';InitialSize = 0; MaximumSize = 0}

# disable DVD drive
Set-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Services\cdrom -Name Start -Value 4 -Type DWord

# change drive letter of scratch disk
$drive = Get-WmiObject -Class win32_volume -Filter "DriveLetter = 'd:'"
Set-WmiInstance -input $drive -Arguments @{ DriveLetter='e:'}

# initialize data disk
Get-Disk | Where partitionstyle -eq 'raw'|
Initialize-Disk -PartitionStyle MBR -PassThru |
New-Partition -AssignDriveLetter -UseMaximumSize |
Format-Volume -FileSystem NTFS -NewFileSystemLabel 'Data' -Confirm:$false

# move pagefile back to scratch disk
$CurrentPageFile = Get-WmiObject -Query 'select * from Win32_PageFileSetting'
$CurrentPageFile.delete()
Set-WMIInstance -Class Win32_PageFileSetting -Arguments @{name='e:\pagefile.sys';InitialSize = 0; MaximumSize = 0}