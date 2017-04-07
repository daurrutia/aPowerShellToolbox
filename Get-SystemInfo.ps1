<#
.Synopsis
   Returns the SystemInfo output of all available AD computers with "server" in the Operating System attribute.
.DESCRIPTION
   *Requires WinRM enabled on target computers.

   Returns the SystemInfo output of all available AD computers with "server" in the Operating System attribute.

   Queries AD for all domain joined computers with "server" in the Operating System attribute.
   Uses Invoke-Command (remoting) to return SystemInfo output as an object.
   
   Thanks to:
   http://techibee.com/powershell/powershell-get-windows-system-info-in-object-format/2450
   https://blogs.msdn.microsoft.com/powershell/2006/11/02/erroraction-and-errorvariable/
   https://mouthclosedearsopen.wordpress.com/2014/10/03/error-handling-vs-invoke-command/  
.EXAMPLE
   Get-SystemInfo
.EXAMPLE
   Get-SystemInfo | Export-Csv .\allInfo.csv -notypeinformation
#>
function Get-SystemInfo
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
        $servers = Get-ADComputer -Filter {operatingsystem -like "*server*"} | sort dnshostname | select -ExpandProperty dnshostname
    }
    Process
    {
        foreach($s in $servers){
            try{
                Invoke-Command -ComputerName $s -ScriptBlock {
                $iobj=systeminfo /FO CSV | ConvertFrom-Csv
                $iobj | Add-Member -MemberType NoteProperty -Name ServicePackMajorVersion -Value (Get-CimInstance -class win32_OperatingSystem | select -ExpandProperty ServicePackMajorVersion) 
                $iobj | Add-Member -MemberType NoteProperty -Name ServicePackMinorVersion -Value (Get-CimInstance -class win32_OperatingSystem | select -ExpandProperty ServicePackMinorVersion)
                $iobj | Add-Member –MemberType NoteProperty –Name 'HotFixID (Last)' –Value (Get-HotFix | sort installedon | select -ExpandProperty HotFixID)[-1]
                $iobj | Add-Member –MemberType NoteProperty –Name 'InstalledBy (Last)' –Value (Get-HotFix | sort installedon | select -ExpandProperty InstalledBy)[-1]
                $iobj | Add-Member –MemberType NoteProperty –Name 'InstalledOn (Last)' –Value (Get-HotFix | sort installedon | select -ExpandProperty InstalledOn)[-1]
                $iobj 
                } -HideComputerName -ErrorAction stop | select -Property * -ExcludeProperty RunspaceId
            }catch{
                $na = 'N/A'
                $iobj = New-Object –TypeName PSObject
                $iobj | Add-Member –MemberType NoteProperty –Name 'Host Name' –Value $s
                $iobj | Add-Member –MemberType NoteProperty –Name 'OS Name' –Value $na
                $iobj | Add-Member –MemberType NoteProperty –Name 'OS Version' –Value $na
                $iobj | Add-Member –MemberType NoteProperty –Name 'OS Manufacturer' –Value $na
                $iobj | Add-Member –MemberType NoteProperty –Name 'OS Configuration' -Value $na
                $iobj | Add-Member –MemberType NoteProperty –Name 'OS Build Type' –Value $na
                $iobj | Add-Member –MemberType NoteProperty –Name 'Registered Owner' –Value $na
                $iobj | Add-Member –MemberType NoteProperty –Name 'Registered Organization' –Value $na
                $iobj | Add-Member –MemberType NoteProperty –Name 'Product ID' –Value $na
                $iobj | Add-Member –MemberType NoteProperty –Name 'Original Install Date' –Value $na
                $iobj | Add-Member –MemberType NoteProperty –Name 'System Boot Time' –Value $na
                $iobj | Add-Member –MemberType NoteProperty –Name 'System Manufacturer' –Value $na
                $iobj | Add-Member –MemberType NoteProperty –Name 'System Model' –Value $na
                $iobj | Add-Member –MemberType NoteProperty –Name 'System Type' –Value $na
                $iobj | Add-Member –MemberType NoteProperty –Name 'Processor(s)' –Value $na
                $iobj | Add-Member –MemberType NoteProperty –Name 'BIOS Version ' –Value $na
                $iobj | Add-Member –MemberType NoteProperty –Name 'Windows Directory' –Value $na
                $iobj | Add-Member –MemberType NoteProperty –Name 'System Directory' –Value $na
                $iobj | Add-Member –MemberType NoteProperty –Name 'Boot Device' –Value $na
                $iobj | Add-Member –MemberType NoteProperty –Name 'System Locale ' –Value $na
                $iobj | Add-Member –MemberType NoteProperty –Name 'Input Locale' –Value $na
                $iobj | Add-Member –MemberType NoteProperty –Name 'Time Zone' –Value $na
                $iobj | Add-Member –MemberType NoteProperty –Name 'Total Physical Memory' –Value $na
                $iobj | Add-Member –MemberType NoteProperty –Name 'Available Physical Memory' –Value $na
                $iobj | Add-Member –MemberType NoteProperty –Name 'Virtual Memory: Max Size' –Value $na
                $iobj | Add-Member –MemberType NoteProperty –Name 'Virtual Memory: Available' –Value $na
                $iobj | Add-Member –MemberType NoteProperty –Name 'Virtual Memory: In Use' –Value $na
                $iobj | Add-Member –MemberType NoteProperty –Name 'Page File Location(s)' –Value $na
                $iobj | Add-Member –MemberType NoteProperty –Name 'Domain' –Value $na
                $iobj | Add-Member –MemberType NoteProperty –Name 'Logon Server' –Value $na
                $iobj | Add-Member –MemberType NoteProperty –Name 'Hotfix(s)' –Value $na
                $iobj | Add-Member –MemberType NoteProperty –Name 'Network Card(s)' –Value $na
                $iobj | Add-Member –MemberType NoteProperty –Name 'Hyper-V Requirements' –Value $na
                $iobj | Add-Member -MemberType NoteProperty -Name ServicePackMajorVersion -Value $na
                $iobj | Add-Member -MemberType NoteProperty -Name ServicePackMinorVersion -Value $na
                $iobj | Add-Member –MemberType NoteProperty –Name 'HotFixID [-1]' –Value $na
                $iobj | Add-Member –MemberType NoteProperty –Name 'InstalledBy [-1]' –Value $na
                $iobj | Add-Member –MemberType NoteProperty –Name 'InstalledOn [-1]' –Value $na
                $iobj
            }
            
        }
        
    }
    End
    {   
    }
}