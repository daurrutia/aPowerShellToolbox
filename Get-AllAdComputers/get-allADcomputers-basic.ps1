#GET ALL ADCOMPUTERS 
#Retrieves basic info (DNSHostName, Enabled, IP, OS, CanonicalName, Created)
#Author: David U.

Write-Debug "Show what's behind those ellipses. Show me all the objects."
$FormatEnumerationLimit = -1

Get-ADComputer -Filter * -Properties DNSHostName,Enabled,IPv4Address,OperatingSystem,CanonicalName,whenCreated |
    Select DNSHostName,Enabled,IPv4Address,OperatingSystem,CanonicalName,whenCreated | Sort DNSHostName | FT -AutoSize