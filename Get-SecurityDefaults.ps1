######### Secrets #########
$ApplicationId = 'cb61efc1-3f69-40f9-a8aa-1681ec582b30'
$ApplicationSecret = 'LMi8J9gy9GhNQUJZ4MO9kJrhpYX/yKEzya43MDir6Ls=' | ConvertTo-SecureString -Force -AsPlainText
$RefreshToken = '0.AUIAh4uuKF6KqkmRflkXMWuVqMHvYctpP_lAqKoWgexYKzBCABk.AgABAAAAAAD--DLA3VO7QrddgJg7WevrAgDs_wQA9P9MYSi4FJ6j0tMQmFFxMMm4MXbSH3y1mzh-aeXp_ACMVgWLVFiDQ8PSGVQn7cFa7ykEoOnjXQziZxQ2cXGUKlslGwaw40Fp_cVTKg2Ho0_GPz7gSdV_bIumHbiNgW3qbNEUa612_ak2bzjguscX-dFwUEtRPAKit7pXFhbzt9DuM2zybEunor43fF9Q7lzFTTRaf5t20Z-7Ytc4B6NSiTv6zHZzhFUJqzbQ-2sJ2J0Tn4RHy83tgW8s73GfHcSiN0Z1cYUZFxZKZ-prmmA2dZvScan08Z9l7myFX6CNaNx14wRSVBJy_rE2ReOo0P36ziGVUerUe-pE7I-aoj6F9znKXnzWESilKymEEyZpUY0F3Ot2d4ZsC1nT98e6Arav6mW9HbdCdKNhP6autXFKIfrNi7cybm7zwSH2U5a1s62XZL0zgQ4ZfIxgpcUVOzVbw_U2aQsuOZMEzDKuVlzsSqETvodXRg6zsJfp9wLoeabSByUrbkyCdX_NxSo7zHrFShISsC5ASA8RIgHlfPpW7mL93F2euUEXfggH3DWB2nyjaFw6rQYPJMsNRFxXZ2XqHVpUwQN1ZUVTE2ytJ8rqvM3ldDzdgyLC9KXQGHZJKQCbQDwPZ_vSkdf5w3CbKlkMiI3q-wIk9NsliPrrh7AVWX_CCdLP0GbT4ViJrXikfHOdA_FNEzd-CmK5h5kNuZIOnbt2C6-WyE8fbxOJs4gE3wlTTlrY7RcEmhtX9NNreYwRsyO9ccWh_zf5_yfGQ-ySILBT8Gt2JmTYqVgm2nbf_sIEIyMs8YyX_ZOZ3Xb_KhDFrJI_jQ4zfvLO2K0COK1yNBTBaKISxFVGHH80oozgsG5BWXAst0rP1m5DkIuswjkZP-HPun8GeadmB2QGsxqkOmnZRv_Fcd0G8lFMVC9Diqnxij4SX4qwyhstAJ-PSk6hdaemAmigG2ly3Wd2krvfrb7LhEsrRq_mBdoRA8IR3Me589Dnu3oE5nOUlfNfyFEjQ8UAehTKYgezLbjVAdmFUY3fA9hcD6jOngdmA-_SLaBHMSCxLRJ5_FkjFzdbNAZ3UN0xS8Jtq-A2QwLhgCmRlHWV2Bw'
######### Secrets #########
$Skiplist = "ongcsystems.onmicrosoft.com", "bla.onmicrosoft.com"
########################## Script Settings  ############################
  
$Baseuri = "https://graph.microsoft.com/beta"
write-host "Generating token to log into Azure AD." -ForegroundColor Green
$credential = New-Object System.Management.Automation.PSCredential($ApplicationId, $ApplicationSecret)
 
$aadGraphToken = New-PartnerAccessToken -ApplicationId $ApplicationId -Credential $credential -RefreshToken $refreshToken -Scopes 'https://graph.windows.net/.default' -ServicePrincipal
$graphToken = New-PartnerAccessToken -ApplicationId $ApplicationId -Credential $credential -RefreshToken $refreshToken -Scopes 'https://graph.microsoft.com/.default'
 
Connect-MsolService -AdGraphAccessToken $aadGraphToken.AccessToken -MsGraphAccessToken $graphToken.AccessToken
  
$customers = Get-MsolPartnerContract -All | Where-Object { $_.DefaultDomainName -notin $skiplist }
 
foreach ($customer in $customers) {
    $CustomerTenant = $customer.defaultdomainname
    $CustGraphToken = New-PartnerAccessToken -ApplicationId $ApplicationId -Credential $credential -RefreshToken $refreshToken -Scopes "https://graph.microsoft.com/.default" -ServicePrincipal -Tenant $CustomerTenant
    $Header = @{
        Authorization = "Bearer $($CustGraphToken.AccessToken)"
    }
 
    $SecureDefaultsState = (Invoke-RestMethod -Uri "$baseuri/policies/identitySecurityDefaultsEnforcementPolicy" -Headers $Header -Method get -ContentType "application/json")
  
    if ($SecureDefaultsState.IsEnabled -eq $true) {
        write-host "Secure Defaults is already enabled for $CustomerTenant."-ForegroundColor Green
    }
    else {
        write-host "Secure Defaults is disabled for $CustomerTenant" -ForegroundColor Yellow
        #$body = '{ "isEnabled": true }'
        #(Invoke-RestMethod -Uri "$baseuri/policies/identitySecurityDefaultsEnforcementPolicy" -Headers $Header -Method patch -Body $body -ContentType "application/json")
        #blablabla
    }
 
}