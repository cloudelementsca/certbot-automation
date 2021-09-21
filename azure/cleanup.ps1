#
# cleanup.ps1
#
# Description: This script removes the TXT record that was added from the auth-hook script after the certificate has been created.
# 
# Authors:
# - Nicholas Briglio
# - Jack Wen

# Remove the _acme-challenge TXT record after the domain has been verified and certificate has been generated
Remove-AzDnsRecordSet -Name $env:TXT_NAME -RecordType TXT -ZoneName $env:CERTBOT_DOMAIN -ResourceGroupName $env:AZ_DNS_RG_NAME
