#
# az-auth.ps1
#
# Description: This script runs as the hook for the certbot certificate creation. It adds a TXT record with the challenge value to the Azure DNS Zone.
# 
# Authors:
# - Nicholas Briglio
# - Jack Wen

# Create the TXT record in the Azure DNS Zone
New-AzDnsRecordSet -Name "_acme-challenge" -RecordType TXT -ZoneName $($env:CERTBOT_DOMAIN) -ResourceGroupName "DNSTestRg" -Ttl 3600 -DnsRecords (New-AzDnsRecordConfig -Value $env:CERTBOT_VALIDATION)

Start-Sleep -Seconds 120