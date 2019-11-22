<#
.Synopsis
   Disables Google Chrome Incognito Mode
.DESCRIPTION
   Disables Google Chrome Incognito Mode on MS Windows.
   Will not overwrite other existing Chrome policies if Chrome registry key is found.
   Chrome policy: http://dev.chromium.org/administrators/policy-list-3#IncognitoModeAvailability
.EXAMPLE
   Disable-IncognitoMode
#>
function Disable-IncognitoMode
{
    [CmdletBinding()]
    Param
    ()

    $path = 'HKLM:\SOFTWARE\Policies\Google\Chrome'

    if (Test-Path $path) {
        New-ItemProperty -Path $path -Name IncognitoModeAvailability -PropertyType DWORD -Value 1 -Force
    }else{
        New-Item -Path HKLM:\SOFTWARE\Policies\Google\Chrome\ -Force | 
        New-ItemProperty -Name IncognitoModeAvailability -PropertyType DWORD -Value 1 -Force
    }
}