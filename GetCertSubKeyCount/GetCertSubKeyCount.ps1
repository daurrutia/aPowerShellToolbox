# GetCertSubKeyCount.ps1
# Author:          David A. Urrutia | 6/2015
# Description:     Gets all AD "server" computers, then
#                  gets the SubKey Count for the Certificates key for each computer.
#                  Adds ComputerName, SubKeyCount, and any Error message(s) to an array.
#                  After looping through all computer names, the array is exported to a CSV file.  

#variable declaration
$array = @() #array to hold custome objects 
$count = 0 #general counter
$keyname = 'SOFTWARE\\Microsoft\\SystemCertificates\\AuthRoot\\Certificates'  #registry target path

#get names from get-adcomputer
Import-Module -Name ActiveDirectory
$computers = Get-ADComputer -Filter {operatingsystem -like "*server*"} | Sort-Object Name

#begin ForEach loop
ForEach ($computer in $computers){
    #pass DNS host name from get-adcomputer result ($computer) to $machine
    $machine = $computer.DNSHostName   
    
    #variable declaration 
    $keyCount = 0
    $time = Get-Date

    #Write to console
    Write-Host $machine $time

    #Error handling
    if ($count -gt 0){$error[0] = $null}
    $noErr = $error[0]
            
    #Check: ping computer
    if(Test-Connection -ComputerName $machine -BufferSize 16 -count 1 -quiet -ErrorAction 0){
        #Get Avg Ping Response Time
        $getResponse = (Test-Connection -ComputerName $machine -Count 4 | Measure-Object -Property ResponseTime -Average).Average
        $avgResponse = ($getResponse -as [int])
        
        #Write to console
        Write-Host $machine "Online; Avg Response = "$avgResponse "ms"
        Write-Host "$machine getting Registry information..."

        #registry target
        $reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $machine) 
        $key = $reg.OpenSubkey($keyname) 
        $keyCount = $key.SubKeyCount

        #Write to console
        Write-Host "$machine 'Certificates' SubKeyCount is $keyCount"
        
        #Create and Add info to object
        $obj = New-Object PSCustomObject 
        $obj | Add-Member -MemberType NoteProperty -Name "ComputerName" -Value $machine 
        $obj | Add-Member -MemberType NoteProperty -Name "SubKeyCount" -Value $keyCount
        $obj | Add-Member -MemberType NoteProperty -Name "Error" -Value N/A

        #Add object to array          
        $array += $obj

    }#end Check: ping computer
    else{ #Ping failed
        #Write to console
        Write-Host -ForegroundColor red "$machine Unreachable"

        #Create and Add info to object
        $obj = New-Object PSCustomObject 
        $obj | Add-Member -MemberType NoteProperty -Name "ComputerName" -Value $machine 
        $obj | Add-Member -MemberType NoteProperty -Name "SubKeyCount" -Value N/A
        $obj | Add-Member -MemberType NoteProperty -Name "Error" -Value "Unreachable"

        #Add object to array          
        $array += $obj

    } #else Ping failed
    
    #Write to console
    Write-Host "- - - - - - - - - - - - - - - -"     #console formatting 

    $count++ #increase  general counter
}#end ForEach loop

#Write to console
Write-Host "End of $count queries."
Get-Date

#file name formatting
$csvFile = "CertSubKeyCount-Report-" + (Get-Date -Format yyyMMddHHmm) + ".csv"

#call array amd export to CSV
$array | select ComputerName,SubKeyCount,Error | Export-Csv $csvFile -NoTypeInformation

#Write to console
Write-Host "CSV file exported to $pwd"


#------------------------------------------
#$machine = Read-Host "Enter computer name" 

#$keyname = 'SOFTWARE\\Microsoft\\SystemCertificates\\AuthRoot\\Certificates'
#$reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $machine) 
#$key = $reg.OpenSubkey($keyname) 
#$keyCount = $key.SubKeyCount

#Write-Host "$machine Certificates SubKeyCount is $keyCount"
#------------------------------------------
#(Get-Item -Path Registry::'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\SystemCertificates\AuthRoot\Certificates').SubKeyCount