Name: GetCertSubKeyCount.ps1
Author: David A. Urrutia | Problem Management
Date: 11/23/2015

Note:
Must be ran from a computer with the Active Directory PowerShell module installed to query AD.
Must be ran with PowerShell version 3.0 or greater.
Must be ran as administrator (elevated PowerShell prompt).
Must have Powershell execution policy set to unrestricted.

Description:
Returns a count of the number of subkeys listed in the third-party certificate store in the registry (Authroot).

Queries Active Directory for all "server" computer objects.
Loops through the queries of computer names.
Each iteration, pings the computer, if not successful lists SubKeyCount as "N/A".
If ping is successful, opens target computer's registry 
(SOFTWARE\\Microsoft\\SystemCertificates\\AuthRoot\\Certificates) and returns a count of the AuthRoot key.
After looping through the list of computer names the data is exported to a CSV.
 
Properties returned:
Computer (Computer name)
SubKeyCount (N/A or a number value)
Error (Unreachable or N/A)