<#
.Synopsis

   Get Active Directory Privileged User Accounts

.DESCRIPTION
    
    Description
    ------------
    Retrieves a list of all AD security groups,
    filters out standard Domain Users/Computers,
    then retrieves each member in each resulting 
    security group, writes the member accounts to 
    a CSV, and finally returns a table of accounts 
    by security group to the screen.

    Requirements
    ------------
    - The Active Directory module for Windows PowerShell on the computer
    running this cmdlet

    Author
    ------------
    Authored by David Urrutia in 2019

.EXAMPLE

   Get-AdPrivilegedAccounts

.EXAMPLE

   Open PowerShell as administrator

    > . C:\path\to\Get-AdPrivilegedAccounts.ps1
    > Get-AdPrivilegedAccounts

#>
function Get-AdPrivilegedAccounts
{
    [CmdletBinding()]
    [Alias()]
    [OutputType([int])]
    Param
    (
    #    # Param1 help description
    #    [Parameter(Mandatory=$true,
    #               ValueFromPipelineByPropertyName=$true,
    #               Position=0)]
    #    $Param1,
    #
    #    # Param2 help description
    #    [int]
    #    $Param2
    )

    Begin
    {

        Import-Module ActiveDirectory

        # CSV Report name
        $title = "AdPrivilegedAccounts"

        # CSV Report save location
        # Note: A path\to\save\directory with no ending '\'
        $location = "C:\Scripts"

        # Create save location, if it doesn't exist
        if(!(Test-Path -Path $location)){
            New-Item -ItemType "directory" -Path $location
        }

        # CSV report location and title
        $report = "$location\$title.csv"

        # AD Security Group Query
        $allGroups = Get-ADGroup -Filter {(Name -ne 'Domain Computers') -and (Name -ne 'Domain Controllers') -and (Name -ne 'Domain Users') -and (Name -ne 'RAS and IAS Servers') -and (Name -ne 'Terminal Server License Servers')} | 
            Sort-Object Name

        # Date formatted for use as a unique identifer
        $date = Get-Date -format "yyyyMMddHHmmss"

    }
    Process
    {

        # Archive report, if one already exsits
        if(Test-Path -Path $report){ 
            Move-Item -Path $report -Destination "$report.$date"
        }
        
        foreach($group in $allGroups){
    
            Get-ADGroupMember -identity $group | Select-Object  @{l="ADGroup";e={$group.name}},name,objectClass,SamAccountName,SID | Sort-Object -Property name | Export-Csv -Path $report -NoTypeInformation -Append
    
        }

        # Write success msg out to screen if a CSV was generated and also open the CSV as a table on-screen
        if(Test-Path -Path $report){ 
            
            Write-Host "A CSV file was generated at $report" -ForegroundColor Green

            Import-Csv -Path $report -Header ADGroup,name,objectClass,SamAccountName,SID | Out-GridView –Title AdPrivilegedUserReport

        }else{
            Write-Error "The export-to-csv process to the location $location failed."
        }

    }
    End
    {
    }
}