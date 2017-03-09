#SetPageFileInfo
#David U. | Operations
#Description: Sets various WMI properties on a list of computers  in local directory (COMPUTERS.TXT).
#Changes: 
#If page file is not automatically configured it will be removed from C: and created on D:
#Sets autoreboot to true
#Enables debug log (dump file) to 3

$computers = Get-Content .\computers.txt
$count = 0

ForEach ($name in $computers){
    #Variable declaration and initilization
    $os = $null
    $osVer = $null
    $pgSettName = $null
    
    #Error handling
    if ($count -gt 0){
        $error[0] = $null
    }
    $noErr = $error[0] 
            
    #Get time
    $time = Get-Date
    
    #output name and time
    Write-Host $name Querying connectivity $time :
    
    #Test if responsive
    if(Test-Connection -ComputerName $name -Count 1 -ErrorAction SilentlyContinue) {     #Successful Ping
        
        #Get Ping Response Time
        $getResponse = (Test-Connection -ComputerName $name -Count 4 | Measure-Object -Property ResponseTime -Average).Average
        $avgResponse = ($getResponse -as [int])
        Write-Host $name "Avg Response = "$avgResponse "ms" 
        
        #Get OS info    
        $os = Get-WmiObject -Class Win32_OperatingSystem -ComputerName $name 
        $osVer = $os.Caption
                
        #Check if error occured (WMI Access is denied/Server unavailable/service) 
        if($error[0] -ne $noErr ){

            Write-Host $name experienced an error.         

        }else{     #Script has access  
            
            #GET Automatically Managed
            $compSys = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $name
            $model = $compSys.Model
                
                           
            #SET Automatically Managed     
            Write-Host "Configuring Automatically Managed Page File setting..."
                
            $compSys.AutomaticManagedPageFile = $false
            $compSys.Put()     #set
                                
            #/SET Automatically Managed

            #Get new automatically managed setting    
            $autoManage = $compSys.AutomaticManagedPageFile     
                
                      
            #SET Manually configured settings     
            if($autoManage){ # if automatically managed set to TRUE
                Write-Host Page file is set to be automatically managed by Windows, and will not be manually reconfigured.
            }else{
            #SET Manually configured settings    
            $currentName = Get-WmiObject -ComputerName $name -query "select * from Win32_PageFileSetting where name='c:\\pagefile.sys'"
            $currentName.Delete()     #delete default page file
                
            $pgSetting.Name = "D:\pagefile.sys"
            $pgSetting.InitialSize = 0
            $pgSetting.MaximumSize = 0
            $pgSetting.Put()     #set
            #/SET Manually configured settings    
            }     #End else

                
            #GET DebugType
            $debugInfo = Get-WmiObject Win32_OSRecoveryConfiguration -ComputerName $name

                
            #SET DebugType
            Write-Host Setting DebugLog Boot settings...
                
            $debugInfo.AutoReboot = $true
            $debugInfo.Put()     #set

            $debugInfo.DebugInfoType = 3
            $debugInfo.Put()    #set

            #/SET DebugType 
               

            #Restart remote computer (Option to immediately restart; Remove # symbol on next two (2) lines to enable.) 
            #(get-wmiobject win32_operatingsystem -computername $name -enableallprivileges).win32shutdowntracker(0,
            #"Page file reconfiguration.",2214723588,6)
            #/Restart remote computer
             

        }     #End Successful Ping actions

    }else{     #Unsuccessful Ping actions
        
        Write-Host $name,"NoReply"

    }     #End Unsuccessful Ping actions

    Write-Host "- - - - - - - - - - - - - - - -"     #Console Formatting
    $count++
}

Write-Host "End of $count iterations" 