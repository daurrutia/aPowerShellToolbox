& C:\Windows\System32\rundll32.exe "C:\Program Files\Windows Photo Viewer\PhotoAcq.dll",PhotoAndVideoAcquire

#<#
#.Synopsis
#   Opens "Import Pictures and Videos" GUI
#.DESCRIPTION
#   Long description
#.EXAMPLE
#   Example of how to use this cmdlet
#.EXAMPLE
#   Another example of how to use this cmdlet
##>
#function import-photosAndVideo
#{
#    [CmdletBinding()]
#    [Alias()]
#    [OutputType([int])]
#    Param
#    (
#        ## Param1 help description
#        #[Parameter(Mandatory=$true,
#        #           ValueFromPipelineByPropertyName=$true,
#        #           Position=0)]
#        #$Param1,
#        #
#        ## Param2 help description
#        #[int]
#        #$Param2
#    )
#
#    Begin
#    {
#    }
#    Process
#    {
#        & C:\Windows\System32\rundll32.exe "C:\Program Files\Windows Photo Viewer\PhotoAcq.dll",PhotoAndVideoAcquire
#    }
#    End
#    {
#    }
#}