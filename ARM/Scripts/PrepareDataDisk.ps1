$Disks = Get-Disk | Where partitionstyle -eq 'raw'
ForEach ($Disk in $Disks)
{
    Initialize-Disk -Number $Disk.Number -PartitionStyle MBR -PassThru
    New-Partition -DiskNumber $Disk.Number -UseMaximumSize -AssignDriveLetter | Format-Volume -FileSystem NTFS -Confirm:$false
}
