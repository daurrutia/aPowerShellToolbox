<#
.Synopsis
   Move FSMO (Operations Master) roles
.DESCRIPTION
   Move Windows server FSMO (Operations Master) roles
   Tested on Windows Server 2012 R2, Windows Server 2008 R2
   Requires Enterprise Admin and Schema Admin membership
   Note: SchemaMaster = 3, PDCEmulator = 0, RIDMaster = 1, InfrastructureMaster = 2, DomainNamingMaster = 4
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>


function Move-FSMO
{
    [CmdletBinding()]
    #[OutputType([int])]
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
        Write-Host "`nIdentifying current role holders...`n"
        netdom.exe query fsmo
        
        $targetSvr = Read-Host "Enter the name of the AD server that receives the roles (ex., DC1, DC02, etc.)"

    }
    Process
    {
        Write-Host "Attempting to move roles..."
        Move-ADDirectoryServerOperationMasterRole -Identity $targetSvr -OperationMasterRole 3,0,1,2,4 -Credential (Get-Credential)
        Write-Host "`nAttempt completed."

    }
    End
    {
        Write-Host "`nIdentifying current role holders...`n"
        netdom.exe query fsmo
    }
}