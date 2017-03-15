<#
.Synopsis
   Get-ComputerUser.ps1 
   Gets printer and user details for a list of computer names.
.DESCRIPTION
   Gets printer and user details for a list of computer names.
   Returns printer WMI details and primary end-user AD details for each computer listed in computers.txt
   **Requires the Configuration Manager (SCCM) module and the Active Directory module
   Tested on Windows Server 2008 R2 and System Center 2012
   Author: David U. | Operations
.EXAMPLE
   Get-ComputerUser
.EXAMPLE
   Another example of how to use this cmdlet
#>
function Get-ComputerUser
{
    [CmdletBinding()]
    #[Alias()]
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
        Write-Debug "Get Text File with Computer Names"
        $computers = Get-Content .\computers.txt
        
        Write-Debug "Create Counter"
        $count = 0
        
        Write-Debug "Create Array"
        $array=@()
        
        Write-Debug "Get Current Directory"
        $currentDir = Get-Location

        Write-Debug "Import AD Module"
        Import-Module ActiveDirectory

        Write-Debug "Set Location to Local CM Module directory"
        CD ‘C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin’
        
        Write-Debug "Import CM Module"
        Import-Module .\ConfigurationManager
        
        Write-Debug "Set Location to CM Site"
        $site = Read-Host "Enter SCCM target site (ex.,T16:, NIH, etc.)"
        CD $site
    }
    Process
    {
        ForEach ($compName in $computers){
            Write-Debug "Declare and initialize variables"
            $ouInfo = "None"
            $dnsName = "None"
            $ip = "None"
            $lastLogOnComp = "None"
            $printName = "None"
            $port = "None"
            $localVal = "None"
            $netVal = "None"
            $userName = "None"
            $displayName = "None"
            $title = "None"
            $company = "None"
            $dept = "None"
            $email = "None"
            $phone = "None"
            $address = "None"
            $office = "None" 
            $room = "None"
            $lastLogOn = "None"
    
            Write-Debug "Check for connectivity"
            if(Test-Connection -ComputerName $compName -BufferSize 16 -Count 1 -Quiet -ErrorAction 0){     
                Write-Debug "Write to console"
                Write-Host -ForegroundColor Green $compName,"Querying device..."

                Write-Debug "Create/Assign Computer Info Variables"
                $ouInfo = Get-ADComputer -Identity $compName -Properties CanonicalName | Select-Object -ExpandProperty CanonicalName
                $dnsName = Get-ADComputer -Identity $compName -Properties DNSHostName | Select-Object -ExpandProperty DNSHostName
                $ip = Get-ADComputer -Identity $compName -Properties IPv4Address | Select-Object -ExpandProperty IPv4Address
                $lastLogOnComp = Get-ADComputer -Identity $compName -Properties LastLogonDate | Select-Object -ExpandProperty LastLogonDate

                Write-Debug "Create/Assign Printer Info Variables"
                $printInfo = GWMI Win32_Printer -CN $compName -Filter "DeviceID LIKE '%HP%' OR DeviceID LIKE '%Xerox%'"
                $printName = ($printInfo.DeviceID -join '; ')
                $port = ($printInfo.PortName -join '; ')
                $localVal = ($printInfo.Local -join '; ')
                $netVal = ($printInfo.Network -join '; ')

                Write-Debug "Create/Assign TopConsoleUser for Computer"
                $userName = Get-CMDevice -Name $compName | Select -expandproperty UserName
                
                Write-Debug "Create/Assign User Info Variables"
                $displayName = Get-ADUser $userName -Properties DisplayName | Select-Object -ExpandProperty DisplayName
                $title = Get-ADUser $userName -Properties Title | Select-Object -ExpandProperty Title
                $company = Get-ADUser $userName -Properties Company | Select-Object -ExpandProperty Company
                $dept = Get-ADUser $userName -Properties Department | Select-Object -ExpandProperty Department
                $email = Get-ADUser $userName -Properties EmailAddress | Select-Object -ExpandProperty EmailAddress
                $phone = Get-ADUser $userName -Properties OfficePhone | Select-Object -ExpandProperty OfficePhone
                $address = Get-ADUser $userName -Properties StreetAddress | Select-Object -ExpandProperty StreetAddress
                $office = Get-ADUser $userName -Properties Office | Select-Object -ExpandProperty Office 
                $room = Get-ADUser $userName -Properties roomNumber | Select-Object -ExpandProperty roomNumber
                $lastLogOn = Get-ADUser $userName -Properties LastLogonDate | Select-Object -ExpandProperty LastLogonDate

                Write-Debug "Create New PS Object"
                $obj = New-Object PSCustomObject
                Write-Debug "Assign All Info to an Object"
                $obj | Add-Member -MemberType NoteProperty -Name "Device" -Value $compName
                $obj | Add-Member -MemberType NoteProperty -Name "CNAME" -Value $ouInfo
                $obj | Add-Member -MemberType NoteProperty -Name "DNSName" -Value $dnsName
                $obj | Add-Member -MemberType NoteProperty -Name "IPAddress" -Value $ip
                $obj | Add-Member -MemberType NoteProperty -Name "DeviceLastLogon" -Value $lastLogOnComp
                $obj | Add-Member -MemberType NoteProperty -Name "PrinterName" -Value $printName
                $obj | Add-Member -MemberType NoteProperty -Name "PortName" -Value $port
                $obj | Add-Member -MemberType NoteProperty -Name "Local" -Value $localVal
                $obj | Add-Member -MemberType NoteProperty -Name "Network" -Value $netVal
                $obj | Add-Member -MemberType NoteProperty -Name "TopConsoleUser" -Value $userName
                $obj | Add-Member -MemberType NoteProperty -Name "DisplayName" -Value $displayName
                $obj | Add-Member -MemberType NoteProperty -Name "Title" -Value $title
                $obj | Add-Member -MemberType NoteProperty -Name "Company" -Value $company
                $obj | Add-Member -MemberType NoteProperty -Name "Department" -Value $dept
                $obj | Add-Member -MemberType NoteProperty -Name "EmailAddress" -Value $email
                $obj | Add-Member -MemberType NoteProperty -Name "OfficePhone" -Value $phone
                $obj | Add-Member -MemberType NoteProperty -Name "StreetAddress" -Value $address
                $obj | Add-Member -MemberType NoteProperty -Name "Office" -Value $office
                $obj | Add-Member -MemberType NoteProperty -Name "RoomNumber" -Value "$room;"
                $obj | Add-Member -MemberType NoteProperty -Name "LastLogonDate" -Value $lastLogOn
                $obj | Add-Member -MemberType NoteProperty -Name "Connectivity" -Value "Online"
                Write-Debug "Add Object to Array"
                $array += $obj


            } 
            Write-Debug "End if"
            Else{
                Write-Host -ForegroundColor Yellow $compName,"No Reply"

                Wrie-Debug "Create New PS Object"
                $obj = New-Object PSCustomObject
                Write-Debug "Assign Info to Object"
                $obj | Add-Member -MemberType NoteProperty -Name "Device" -Value $compName
                $obj | Add-Member -MemberType NoteProperty -Name "CNAME" -Value "N/A"
                $obj | Add-Member -MemberType NoteProperty -Name "DNSName" -Value "N/A"
                $obj | Add-Member -MemberType NoteProperty -Name "IPAddress" -Value "N/A"
                $obj | Add-Member -MemberType NoteProperty -Name "DeviceLastLogon" -Value "N/A"
                $obj | Add-Member -MemberType NoteProperty -Name "PrinterName" -Value "N/A"
                $obj | Add-Member -MemberType NoteProperty -Name "PortName" -Value "N/A"
                $obj | Add-Member -MemberType NoteProperty -Name "Local" -Value "N/A"
                $obj | Add-Member -MemberType NoteProperty -Name "Network" -Value "N/A"
                $obj | Add-Member -MemberType NoteProperty -Name "TopConsoleUser" -Value "N/A"
                $obj | Add-Member -MemberType NoteProperty -Name "DisplayName" -Value "N/A"
                $obj | Add-Member -MemberType NoteProperty -Name "Title" -Value "N/A"
                $obj | Add-Member -MemberType NoteProperty -Name "Company" -Value "N/A"
                $obj | Add-Member -MemberType NoteProperty -Name "Department" -Value "N/A"
                $obj | Add-Member -MemberType NoteProperty -Name "EmailAddress" -Value "N/A"
                $obj | Add-Member -MemberType NoteProperty -Name "OfficePhone" -Value "N/A"
                $obj | Add-Member -MemberType NoteProperty -Name "StreetAddress" -Value "N/A"
                $obj | Add-Member -MemberType NoteProperty -Name "Office" -Value "N/A"
                $obj | Add-Member -MemberType NoteProperty -Name "RoomNumber" -Value "N/A"
                $obj | Add-Member -MemberType NoteProperty -Name "LastLogonDate" -Value "N/A"
                $obj | Add-Member -MemberType NoteProperty -Name "Connectivity" -Value "Offline"
                Write-Debug "Add Object to Array"
                $array += $obj

            } 
            Write-Debug "End Else"

            Write-Debug "Increase device counter"
            $count++


        }
        Write-Debug "End ForEach"
    }
    End
    {
        Write-Debug "Set Location to Original Directory"
        Set-Location -Path $currentDir

        Write-Debug "Call Array and Output to CSV"
        $array | Select Device,CNAME,DNSName,IPAddress,DeviceLastLogon,PrinterName,PortName,
        Local,Network,TopConsoleUser,DisplayName,Title,Company,Department,EmailAddress,
        OfficePhone,StreetAddress,Office,RoomNumber,LastLogonDate,Connectivity | 
        Export-Csv Computer-User-Report-.csv -NoTypeInformation

        Write-Host "End of $count computer iterations."
    }
}
