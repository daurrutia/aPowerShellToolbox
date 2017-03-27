<#
.Synopsis
   Gets disk information for all domain joined computers.
.DESCRIPTION
   Returns system name, device id, drive type, filesystem, 
   size, used, free space, and % free space.

   Uses the CIM logicaldisk class (WMI).
   Get-CimInstance -ClassName win32_logicaldisk -Filter drivetype=3 | select *
   Get-CimInstance -ClassName cim_logicaldisk | Select-Object SystemName,DeviceID,@{n="Size";e={[math]::Round($_.Size/1GB,2)}},@{n="Used";e={[math]::Round(($_.Size - $_.FreeSpace) /1GB,2)}} ,@{n="FreeSpace";e={[math]::Round($_.FreeSpace/1GB,2)}} 

   Author: David U. | Engineeering
.EXAMPLE
   Get-DiskInfo
.EXAMPLE
   Get-DiskInfo | Export-Csv myDisks.csv
#>
function Get-DiskInfo
{
    [CmdletBinding()]
    #[OutputType([int])]
    Param
    (
        ## Param1 help description
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
    }
    Process
    {

        #WinRM enabled
        foreach($c in (Get-ADComputer -Filter * | sort dnshostname | select -ExpandProperty dnshostname -Verbose)){
            if (Test-Connection $c -Count 1 -Quiet -Verbose){
        
                Invoke-Command -ComputerName $c -ScriptBlock {
                    Get-CimInstance -ClassName cim_logicaldisk | 
                    Select-Object SystemName,DeviceID,DriveType,FileSystem,@{n="Size";e={[math]::Round($_.Size/1GB,2)}},@{n="Used";e={[math]::Round(($_.Size - $_.FreeSpace) /1GB,2)}} ,@{n="FreeSpace";e={[math]::Round($_.FreeSpace/1GB,2)}},@{n="%FreeSpace";e={[math]::Round(($_.FreeSpace*100)/$_.Size)}}
                } -HideComputerName -Verbose
        
                #Invoke-Command -ComputerName $c -ScriptBlock {Get-PSDrive -PSProvider FileSystem}
            }else{
                $na = "N/A"
                Write-Debug "Unable to reach $SystemName"
                $object = New-Object –TypeName PSObject
                $object | Add-Member –MemberType NoteProperty –Name SystemName –Value $c
                $object | Add-Member –MemberType NoteProperty –Name DeviceID –Value $na
                $object | Add-Member –MemberType NoteProperty –Name DriveType –Value $na
                $object | Add-Member –MemberType NoteProperty –Name FileSystem –Value $na
                $object | Add-Member –MemberType NoteProperty –Name Size –Value $na
                $object | Add-Member –MemberType NoteProperty –Name Used –Value $na
                $object | Add-Member –MemberType NoteProperty –Name FreeSpace –Value $na
                $object | Add-Member –MemberType NoteProperty –Name %FreeSpace –Value $na
                $object | Add-Member –MemberType NoteProperty –Name RunspaceId –Value $na
                Write-Output $object -Verbose
            }
        }


    }
    End
    {
    }

}
