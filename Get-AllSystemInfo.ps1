<#
.Synopsis
   Exports the SystemInfo output of all available AD computers to a CSV.
.DESCRIPTION
   *Requires WinRM enabled on all AD-joined computers
   
   Exports the SystemInfo output of all available AD computers to a CSV.
   Queries AD for all domain joined computers.
   Creates a temporary folder on the C: drive on retunred remote AD computers. 
   Runs and exports the Windows SystemInfo tool output to a CSV file within the temporary folder on remote computers.
   Imports the CSVs into PowerShell and exports the consolidated output as a single CSV to a local file path.
   Removes the temporary folder on remote AD computers.
   
   Error Handling: No error handling configured. Computers that are unreachable (offline) or do not have WinRM enabled
   will return exceptions.  
.EXAMPLE
   Get-AllSystemInfo

   Enter a valid local path to receive the SystemInfo CSV (ex., C:\SystemInfo, C:\Reports, etc.): C:\AllSystemInfo

   Connecting to remote computers and gathering SystemInfo. Please wait...

   Completed.

   Would you like to open SystemInfo20170101120001.csv ? (y|n): 
.EXAMPLE
   Get-AllSystemInfo

   Enter a valid local path to receive the SystemInfo CSV (ex., C:\SystemInfo, C:\Reports, etc.): C:\AllSystemInfo

   Connecting to remote computers and gathering SystemInfo. Please wait...

   [SVR15] Connecting to remote server SVR15 failed with the following error message : The client cannot connect to the destination specified in the 
   request. Verify that the service on the destination is running and is accepting requests. Consult the logs and documentation for the WS-Management service running on the 
   destination, most commonly IIS or WinRM. If the destination is the WinRM service, run the following command on the destination to analyze and configure the WinRM 
   service: "winrm quickconfig". For more information, see the about_Remote_Troubleshooting Help topic.
       + CategoryInfo          : OpenError: (SVR15:String) [], PSRemotingTransportException
       + FullyQualifiedErrorId : CannotConnect,PSSessionStateBroken

   Completed.

   Would you like to open SystemInfo20170101120001.csv ? (y|n):
#>
function Get-AllSystemInfo
{
    [CmdletBinding()]
    #[OutputType([int])]
    Param
    (
        # Param1 help description
        #[Parameter(Mandatory=$true,
        #           ValueFromPipelineByPropertyName=$true,
        #           Position=0)]
        #$Param1,
        #
        ## Param2 help description
        #[int]
        #$Param2
    )

    Begin
    {
        Do{
            $exportPath = Read-Host "`nEnter a valid local path to receive the SystemInfo CSV (ex., C:\SystemInfo, C:\Reports, etc.)"
        }While (((Test-Path $exportPath) -ne $true) -or ($exportPath -eq "C:\") -or ($exportPath -eq "C:"))

        $csvName = "SystemInfo"+(Get-Date -Format yyyyMMddHHmmss)
    }
    Process
    {
        Write-Host "`nConnecting to remote computers and gathering SystemInfo. Please wait..."
      
        Invoke-Command -ComputerName (Get-ADComputer -Filter * | select -ExpandProperty Name) -ScriptBlock {
            $localCsv = "$env:computername-$Using:csvName.csv"
            $path = "C:\$localCsv"  

            systeminfo /fo csv > $path

            Import-Csv $path

        }  | Export-Csv -Path $exportPath\$csvName.csv -NoTypeInformation  
    }
    End
    {
        Invoke-Command -ComputerName (Get-ADComputer -Filter * | select -ExpandProperty Name) -ScriptBlock {
            $localCsv = "$env:computername-$Using:csvName.csv"
            Remove-Item -Path C:\$localCsv -Recurse
        }

        Write-Host "Completed."

        $openFile = Read-Host "`nWould you like to open $csvName.csv ? (y|n)"
        if($openFile -eq "y"){Invoke-Item "$exportPath\$csvName.csv"}
    }
}