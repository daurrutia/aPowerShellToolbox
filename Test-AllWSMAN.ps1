<#
.Synopsis
   Tests to see if WSMAN (WinRM) is running on ALL domain joined computers.
.DESCRIPTION
   Tests to see if WSMAN (WinRM) is running on ALL domain joined computers.
   Gets all AD joined computer names.
   Iteratively test the connection to each computer with 1 ping.
   If ping returns successful, uses the Test-WSMAN cmdlet to test WinRM capability.
   Assigns output to an object and outputs the object.
   If ping does not return successfully, an object is created stating the computer is 
   offline and the WinRM status is unknown and outputs the object.

   Author: David U. | Engineering
.EXAMPLE
   Test-AllWSMAN
.EXAMPLE
   Test-AllWSMAN | Export-Csv winrmEnabled.csv
#>
function Test-AllWSMan
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

        foreach ($c in (Get-ADComputer -Filter * | sort dnshostname | select -ExpandProperty dnshostname)){
            if(Test-Connection $c -Quiet -Count 1){
                $rm = $null
                if (Test-WSMan $c){$rm = "Ready"}else{$rm = "Not Ready"}
                $obj = new-object psobject
                $obj | add-member noteproperty Name -value $c
                $obj | add-member noteproperty Status -value "Online"
                $obj | add-member noteproperty WinRM -value $rm
                Write-Output $obj 
            }else{
                $obj = new-object psobject
                $obj | add-member noteproperty Name -value $c
                $obj | add-member noteproperty Status -value "Offline"
                $obj | add-member noteproperty WinRM -value "Unknown"
                Write-Output $obj 
            }
        }

    }
    End
    {
    }
}
