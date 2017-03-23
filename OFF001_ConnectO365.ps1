##Description: Script to connect to Office 365. Runs in regular Powershell
##Prerequisites: NA
##Author: Serge de Klerk
##Version: 1.0

# Get O365 administrator’s full O365 email, for example, name@domain.onmicrosoft.com and password
$UserCredential = Get-Credential

# Connect to O365
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection 
Import-PSSession $Session