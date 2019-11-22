
<#
.Synopsis
   Disables Microsoft Edge InPrivate Browsing
.DESCRIPTION
   Disables Microsoft Edge InPrivate Browsing

   https://docs.microsoft.com/en-us/windows/client-management/mdm/policy-csp-browser#browser-allowinprivate
   https://github.com/MicrosoftDocs/windows-itpro-docs/blob/master/browsers/edge/includes/allow-inprivate-browsing-include.md
.EXAMPLE
   .\disable-inprivate.ps1
#>

$path = 'HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\Main'

if (Test-Path $path) {
    New-ItemProperty -Path $path -Name AllowInPrivate -PropertyType DWORD -Value 0 -Force
}else{
    New-Item -Path $path -Force | 
    New-ItemProperty -Name AllowInPrivate  -PropertyType DWORD -Value 0 -Force
}