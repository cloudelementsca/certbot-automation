# certbot-automation

This repo contains scripts to automatically create (renew) certificates with Let's Encrypt using certbot by leveraging an Azure DevOps YAML pipeline. It deploys the newly obtained certificate to an Azure KeyVault.

It covers two scenarios: 
- Create Let's Encrypt certificate using Certbot and deploy to Azure KeyVault with Azure DNS Zone
- Create Let's Encrypt certificate using Certbot and deploy to Azure KeyVault with GoDaddy

# Prerequisites
## Azure DNS Zone
### Azure Resources
- Azure DNS Zone
- Azure KeyVault

### Azure RBAC
- Contributor on Azure DNS Zone
- Import permissions in Access Policies on the Azure KeyVault
## Service Providers 
### GoDaddy
- [Developer account with API credentials](https://developer.godaddy.com/) from GoDaddy

### Azure Resources
- Azure KeyVault with import permissions access policy

# Azure DNS Zone
The `azure/` folder contains PowerShell scripts that will request a certificate from Let's Encrypt using certbot on a Windows Agent, and update an Azure DNS Zone with the required TXT record. 

`az-renew-cert.ps1`
- installs certbot
- installs openssl with chocolatey
- runs certbot command to create certificate
- imports certificate to keyvault

`az-auth.ps1` 
- runs before certbot tries to validate the domain via the `--manual-auth-hook` flag
- adds TXT record to Azure DNS Zone

`cleanup.ps1`
- runs after certbot has completed verification process via `--manual-cleanup-hook`
- removes the TXT record that was added from the `--manual-auth-hook`

# Service Providers
### GoDaddy
The `service-provider/` folder contains shell scripts that will request a certificate from Let's Encrypt using certbot on a Linux Agent, and update a GoDaddy DNS Zone with the required TXT record using their [REST API](https://developer.godaddy.com/doc/endpoint/domains#/v1/recordReplaceTypeName). 

`renew-cert.sh` 
- installs certbot via snap
- runs certbot command to create certificate
- imports certificate to keyvault

`godaddy-auth.sh` 
- runs before certbot tries to validate the domain via the `--manual-auth-hook` flag
- adds TXT record to GoDaddy domain via REST API

`cleanup.sh`
- runs after certbot has completed verification process via `--manual-cleanup-hook`
- removes the TXT record that was added from the `--manual-auth-hook`

# Pipeline
- The Azure DevOps pipeline is split into 2 jobs separating the [GoDaddy](#godaddy) and [Azure DNS Zone](#azure-dns-zone) tasks. 
- The service principal (service connection) used to run the pipeline must have at least contributor on the Azure DNS Zone, and import permissions in the Azure KeyVault access policies. 
- Replace the `serviceConnection` variable with the name of your service connection. 
- The pipeline uses a variable group containing a secret variable with the password for the private key. The replace token task is configured to replace tokens with pattern `__<variable>__` in all files in the folder matching variable names.