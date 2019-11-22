# GetCompInfo.ps1

Note:

- Must be ran as administrator.
- Must be given user input.
- Must be ran on computer with the Active Directory PowerShell module installed to query AD.
- Must be ran from same directory as COMPUTERS.TXT to read names from the file.

Name:        GetCompInfo.ps1  
Author:      David A. Urrutia  
Description:  
Exports a CSV report of WMI objects of computers retrieved from COMPUTERS.TXT or AD (servers only).

ComputerName,OS,SP,InstallDate,LastBootTime,Manufacturer,Model,"PhysicalMemory(GB)",NumOfProcessors,  
NumOfCores,NumOfLogicalProcessors,"SerialNumber(BIOS)","SerialNumber(Encl)",LogicalDrives,PageFile

In order to query AD, the Powershell AD Module must be installed on the computer on which the script is running.
