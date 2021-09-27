#
# az-create-cert.ps1
#
# Description: This script installs certbot, runs the renewal/creation command, converts the certificate to .pfx, then uploads to a key vault.
# 
# Authors:
# - Nicholas Briglio
# - Jack Wen

# Change these variables based on your domain info
$domain             = "subdomain.cloudelements.ca"
$certFileName       = "subdomain-cloudelements-ca"
$email              = "info@cloudelements.ca"
$keyVaultName       = "snbdnstestkv"
$authHookPath       = "$($env:SYSTEM_DEFAULTWORKINGDIRECTORY)\azure\az-auth.ps1"
$cleanupHookPath    = "$($env:SYSTEM_DEFAULTWORKINGDIRECTORY)\azure\cleanup.ps1"
$env:AZ_DNS_RG_NAME = "DNSTestRg"
$env:TXT_NAME       = "_acme-challenge"

# install openssl
choco install openssl --no-progress

# Install certbot
Invoke-WebRequest -Uri https://dl.eff.org/certbot-beta-installer-win32.exe -OutFile "$($env:SYSTEM_DEFAULTWORKINGDIRECTORY)\certbot-beta-installer-win32.exe"

cd $($env:SYSTEM_DEFAULTWORKINGDIRECTORY)

# /D not working
Start-Process -Wait -FilePath ".\certbot-beta-installer-win32.exe" -ArgumentList "/S" -PassThru

cd "C:\Program Files (x86)\Certbot\bin"

# Request a new certificate
.\certbot.exe certonly --manual --preferred-challenges=dns --manual-auth-hook $authHookPath -d $domain --email $email --manual-cleanup-hook $cleanupHookPath --agree-tos -n

cd "C:\Certbot\live\$domain\"

# Convert certificate to .pfx
openssl pkcs12 -export -out "$certFileName.pfx" -inkey privkey.pem -in fullchain.pem -passout pass:__PKPWD__

# Import certificate to KeyVault
# __PKPWD__ is a secret pipeline (group) variable whose value is mapped to a KV secret
$password = ConvertTo-SecureString -String __PKPWD__ -AsPlainText -Force
Import-AzKeyVaultCertificate -VaultName $keyVaultName -Name $certFileName -FilePath "$certFileName.pfx" -Password $password
