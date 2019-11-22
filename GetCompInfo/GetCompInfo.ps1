# Name:        GetCompInfo.ps1
# Author:      David A. Urrutia 
# 6/2015
# Description: Exports a CSV report of WMI objects of computers retrieved from COMPUTERS.TXT or AD (servers only).
#             (ComputerName,OS,SP,InstallDate,LastBootTime,Manufacturer,Model,"PhysicalMemory(GB)",NumOfProcessors,
#             NumOfCores,NumOfLogicalProcessors,"SerialNumber(BIOS)","SerialNumber(Encl)",LogicalDrives,PageFile)
#             In order to query AD, the Powershell AD Module must be installed on the computer on which the script is running.

#Variable declaration
$array =@()
$count = 0
$countIn = 0
#$currtime = Get-Date
$useList = $False
$input = $False

#read user input
Do{
    if($countIn -gt 0){Write-Host "Please enter Yes or No."}

    $readText = Read-Host "Would you like to use a list of computers in COMPUTERS.TXT? (Yes or No)"
    
    $yesIn = "yes"
    $noIn = "no"
    $userInYesComp = [string]::Compare($readText,$yesIn,$True)
    $userInNoComp = [string]::Compare($readText,$noIn,$True)

    if(!$userInYesComp){
        $input = $True
        $useList = $True
        Write-Host "GET-ADComputer will not be used. COMPUTERS.TXT will be used." #TEST
    }#end if

    if(!$userInNoComp){
        $input = $True
        Write-Host "COMPUTERS.TXT will not be used. GET-ADComputer will be used." #TEST
    }#end if
    
    $countIn++

}While(!$input)

Write-Host "- - - - - - - - - - - - - - - -"     #console formatting

#get machine names
if($useList){
    #get names from file
    $computers = Get-Content .\computers.txt
}else{
    #get names from get-adcomputer
    Import-Module -Name ActiveDirectory
    $computers = Get-ADComputer -Filter {operatingsystem -like "*server*"} | Sort-Object Name
}

#begin ForEach loop
ForEach ($computer in $computers){
    #variable declaration
    $time = Get-Date
    $osVer = "N/A"
    $osSP = "N/A"
    $osDate ="N/A"
    $osBoot = "N/A"
    $make = "N/A"
    $model = "N/A"
    $memGB = "N/A"
    $numProc = "N/A"
    $logProc = "N/A"
    $corProc = "N/A"
    $biosSerial = "N/A"
    $encSerial = "N/A"
    $drivelist = "N/A"
    $pgName = "N/A"
    
    if($useList){
        #pass computer name to $machine
        $machine = $computer
    }else{
        #pass DNS host name from get-adcomputer result to $machine
        $machine = $computer.DNSHostName
    }   
    
    #Error handling
    if ($count -gt 0){$error[0] = $null}
    $noErr = $error[0]
    #/Error handling

    Write-Host $machine $time

    #ping computer
    if(Test-Connection -ComputerName $machine -BufferSize 16 -count 1 -quiet -ErrorAction 0){
        
        #Get Ping Response Time
        $getResponse = (Test-Connection -ComputerName $machine -Count 4 | Measure-Object -Property ResponseTime -Average).Average
        $avgResponse = ($getResponse -as [int])
        Write-Host $machine "Online; Avg Response = "$avgResponse "ms"
        #end Get Ping Response Time
        
        #get WMI OS info   
            $os = Get-WmiObject -Class Win32_OperatingSystem -ComputerName $machine
            $osVer = $os.Caption
            $osSP = $os.ServicePackMajorVersion
            $osDate = $os.InstallDate
            $osBoot = $os.LastBootUpTime 

            #CHECK wmi latency 
            if($error[0] -eq $noErr){
                $timeoutVal =  Measure-Command {Get-WmiObject -Class Win32_OperatingSystem -ComputerName $machine | Select Caption}
                $timeoutValSec = $timeoutVal.TotalSeconds
                if($timeoutValSec -gt 35){
                    $error[0] = "Error: WMI timeout value reached."
                    Write-Host -ForegroundColor Red "Error: WMI timeout value reached."
                }#end if sec > threshold
            }#end if wmi latency check

            #if an error occured attempting to read the OS caption it is stored in $error
        #/Get OS info

        #Check if error occured (Access is denied/Server unavailable/service, etc.) 
        if($error[0] -eq $noErr ){     #no error logged in $error
            #Begin WMI queries
            
            Write-Host -ForegroundColor green  "$machine getting WMI information..."

            #computer info
            $compSys=Get-WmiObject -Class Win32_ComputerSystem -Computername $machine
            $make = $compSys.manufacturer
            $model = $compSys.model
            $memGB = [math]::Round(($compSys.TotalPhysicalMemory / 1GB),2)
            
            #processor
            $proc = Get-WmiObject -Class Win32_Processor -Computername $machine
            $numProc = $compSys.NumberofProcessors
            $logProc = ($proc.NumberofLogicalProcessors -join ',')
            $corProc = ($proc.NumberOfCores -join ',')
			
            #BIOS
            $bios = Get-WmiObject -Class Win32_BIOS -Computername $machine
            $biosSerial = $bios.serialnumber
            
            #enclosure info		
            $sysEnc = Get-WmiObject -Class Win32_SystemEnclosure -ComputerName $machine
            $encSerial = $sysEnc.serialnumber
            
            #Logical drives
            $driveInfo = Get-WmiObject win32_logicaldisk -ComputerName $machine -filter "drivetype=3"
            $driveList = ($driveInfo.DeviceID -join ',')

            #PageFile usage info
            $pgUsage = Get-WmiObject -Class Win32_PageFileUsage -ComputerName $machine
            $pgName = ($pgUsage.Name -join ',')
            
            #Create and Add info to object
            $obj = New-Object PSCustomObject 
            $obj | Add-Member -MemberType NoteProperty -Name "ComputerName" -Value $machine 
            $obj | Add-Member -MemberType NoteProperty -Name "OS" -Value $osVer
            $obj | Add-Member -MemberType NoteProperty -Name "SP" -Value $osSP
            $obj | Add-Member -MemberType NoteProperty -Name "InstallDate" -Value $osDate
            $obj | Add-Member -MemberType NoteProperty -Name "LastBootTime" -Value $osBoot
            $obj | Add-Member -MemberType NoteProperty -Name "Manufacturer" -Value $make
            $obj | Add-Member -MemberType NoteProperty -Name "Model" -Value $model
            $obj | Add-Member -MemberType NoteProperty -Name "PhysicalMemory(GB)" -Value $memGB
            $obj | Add-Member -MemberType NoteProperty -Name "NumOfProcessors" -Value $numProc
            $obj | Add-Member -MemberType NoteProperty -Name "NumOfCores" -Value $corProc
            $obj | Add-Member -MemberType NoteProperty -Name "NumOfLogicalProcessors" -Value $logProc
            $obj | Add-Member -MemberType NoteProperty -Name "SerialNumber(BIOS)" -Value $biosSerial
            $obj | Add-Member -MemberType NoteProperty -Name "SerialNumber(Encl)" -Value $encSerial
            $obj | Add-Member -MemberType NoteProperty -Name "LogicalDrives" -Value $driveList
            $obj | Add-Member -MemberType NoteProperty -Name "PageFile" -Value $pgName
            $obj | Add-Member -MemberType NoteProperty -Name "Error" -Value "N/A"
                        
            #Add object to array          
            $array += $obj

        }#end if error equals no error
        else{ #error did occur
            $osVer = "N/A"
            $osSP = "N/A"
            $osDate ="N/A"
            $osBoot = "N/A"

            Write-Host -ForegroundColor red  "$machine error occured." $error[0]

            #Create and Add info to object
            $obj = New-Object PSCustomObject 
            $obj | Add-Member -MemberType NoteProperty -Name "ComputerName" -Value $machine 
            $obj | Add-Member -MemberType NoteProperty -Name "OS" -Value $osVer
            $obj | Add-Member -MemberType NoteProperty -Name "SP" -Value $osSP
            $obj | Add-Member -MemberType NoteProperty -Name "InstallDate" -Value $osDate
            $obj | Add-Member -MemberType NoteProperty -Name "LastBootTime" -Value $osBoot
            $obj | Add-Member -MemberType NoteProperty -Name "Manufacturer" -Value $make
            $obj | Add-Member -MemberType NoteProperty -Name "Model" -Value $model
            $obj | Add-Member -MemberType NoteProperty -Name "PhysicalMemory(GB)" -Value $memGB
            $obj | Add-Member -MemberType NoteProperty -Name "NumOfProcessors" -Value $numProc
            $obj | Add-Member -MemberType NoteProperty -Name "NumOfCores" -Value $corProc
            $obj | Add-Member -MemberType NoteProperty -Name "NumOfLogicalProcessors" -Value $logProc
            $obj | Add-Member -MemberType NoteProperty -Name "SerialNumber(BIOS)" -Value $biosSerial
            $obj | Add-Member -MemberType NoteProperty -Name "SerialNumber(Encl)" -Value $encSerial
            $obj | Add-Member -MemberType NoteProperty -Name "LogicalDrives" -Value $driveList
            $obj | Add-Member -MemberType NoteProperty -Name "PageFile" -Value $pgName
            $obj | Add-Member -MemberType NoteProperty -Name "Error" -Value $error[0]
                        
            #Add object to array          
            $array += $obj

        }#end else if error did occur

    }#end if test-connection

    else{ #test-connection false
        
        Write-Host -ForegroundColor red "$machine Unreachable"

        #Create and Add info to object
            $obj = New-Object PSCustomObject 
            $obj | Add-Member -MemberType NoteProperty -Name "ComputerName" -Value $machine 
            $obj | Add-Member -MemberType NoteProperty -Name "OS" -Value $osVer
            $obj | Add-Member -MemberType NoteProperty -Name "SP" -Value $osSP
            $obj | Add-Member -MemberType NoteProperty -Name "InstallDate" -Value $osDate
            $obj | Add-Member -MemberType NoteProperty -Name "LastBootTime" -Value $osBoot
            $obj | Add-Member -MemberType NoteProperty -Name "Manufacturer" -Value $make
            $obj | Add-Member -MemberType NoteProperty -Name "Model" -Value $model
            $obj | Add-Member -MemberType NoteProperty -Name "PhysicalMemory(GB)" -Value $memGB
            $obj | Add-Member -MemberType NoteProperty -Name "NumOfProcessors" -Value $numProc
            $obj | Add-Member -MemberType NoteProperty -Name "NumOfCores" -Value $corProc
            $obj | Add-Member -MemberType NoteProperty -Name "NumOfLogicalProcessors" -Value $logProc
            $obj | Add-Member -MemberType NoteProperty -Name "SerialNumber(BIOS)" -Value $biosSerial
            $obj | Add-Member -MemberType NoteProperty -Name "SerialNumber(Encl)" -Value $encSerial
            $obj | Add-Member -MemberType NoteProperty -Name "LogicalDrives" -Value $driveList
            $obj | Add-Member -MemberType NoteProperty -Name "PageFile" -Value $pgName
            $obj | Add-Member -MemberType NoteProperty -Name "Error" -Value "Unreachable"
                        
            #Add object to array          
            $array += $obj

    }#end else test-connection false
    
    Write-Host "- - - - - - - - - - - - - - - -"     #console formatting
    
    $count++

}#end ForEach

Write-Host "End of $count queries."

$csvFile = "ComputerInfo-Report-" + (Get-Date -Format yyyMMddHHmm) + ".csv"

$array | select ComputerName,OS,SP,InstallDate,LastBootTime,Manufacturer,Model,"PhysicalMemory(GB)",NumOfProcessors,
NumOfCores,NumOfLogicalProcessors,"SerialNumber(BIOS)","SerialNumber(Encl)",LogicalDrives,PageFile,
Error | Export-Csv $csvFile -NoTypeInformation

Write-Host "CSV file exported to $pwd"