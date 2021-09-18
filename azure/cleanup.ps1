#
# cleanup.ps1
#
# Description: This script removes the TXT record that was added from the auth-hook script after the certificate has been created.
# 
# Authors:
# - Nicholas Briglio
# - Jack Wen

# Remove the _acme-challenge TXT record after the domain has been verified and certificate has been generated
Remove-AzDnsRecordSet -Name "_acme-challenge" -RecordType TXT -ZoneName "subdomain.cloudelements.ca" -ResourceGroupName "DNSTestRg"
