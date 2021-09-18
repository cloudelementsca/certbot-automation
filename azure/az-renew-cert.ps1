#
# az-create-cert.ps1
#
# Description: This script installs certbot, runs the renewal/creation command, converts the certificate to .pfx, then uploads to a key vault.
# 
# Authors:
# - Nicholas Briglio
# - Jack Wen

# Change these variables based on your domain info
$domain             = $env:CERTBOT_DOMAIN
$certFileName       = "subdomain-cloudelements-ca.pfx"
$keyVaultName       = "snbdnstestkv"
$authHookPath       = "$($env:SYSTEM_DEFAULTWORKINGDIRECTORY)\azure\az-auth.ps1"
$cleanupHookPath    = "$($env:SYSTEM_DEFAULTWORKINGDIRECTORY)\azure\cleanup.ps1"

# install openssl
choco install openssl

# Install certbot
Invoke-WebRequest -Uri https://dl.eff.org/certbot-beta-installer-win32.exe -OutFile "$($env:SYSTEM_DEFAULTWORKINGDIRECTORY)\certbot-beta-installer-win32.exe"

cd $($env:SYSTEM_DEFAULTWORKINGDIRECTORY)

Start-Process -Wait -FilePath ".\certbot-beta-installer-win32.exe" -ArgumentList "/S /D=$env:SYSTEM_DEFAULTWORKINGDIRECTORY" -PassThru

cd "C:\Program Files (x86)\Certbot\bin"

# Request a new certificate
.\certbot.exe certonly --manual --preferred-challenges=dns --manual-auth-hook $authHookPath -d $domain --manual-cleanup-hook $cleanupHookPath --agree-tos -n

cd "C:\Certbot\live\$domain\"

# Convert certificate to .pfx
openssl pkcs12 -export -out $certFileName -inkey privkey.pem -in fullchain.pem -passout pass:__PKPWD__

# Import certificate to KeyVault
$Password = ConvertTo-SecureString -String __PKPWD__ -AsPlainText -Force
Import-AzKeyVaultCertificate -VaultName $keyVaultName -Name $domain -FilePath $certFileName -Password $Password
