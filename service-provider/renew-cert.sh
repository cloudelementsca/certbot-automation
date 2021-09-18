#
# renew-cert.sh
#
# Description: This script add the TXT recoord "_acme-challenge" with Cerbot generated value.
#
# Authors:
# - Jack Wen
# - Nicholas Briglio

# Change these variables based on your domain info
$domain           = "cloudelements.ca"
$email            = "nicholas.briglio@cloudelements.ca"
$privkeypath      = "/etc/letsencrypt/live/cloudelementss.ca/privkey.pem"
$fullchainpath    = "/etc/letsencrypt/live/cloudelementss.ca/fullchain.pem"
$certFileName     = "subdomain-cloudelements-ca.pfx"
$vaultname        = "snbdnstestkv"
$cert_name        = "subdomain-cloudelements-ca"
$authHookPath     = "./auth.sh"
$cleanupHookPath  = "./cleanup.sh"

# Setup certbot in agent
# Ensure that your version of snapd is up to date
sudo snap install core; sudo snap refresh core

# Remove certbot-auto and any Certbot OS packages
sudo apt-get remove certbot

# Install Certbot
sudo snap install --classic certbot

# Prepare the Certbot command
sudo ln -s /snap/bin/certbot /usr/bin/certbot

ls -l

sudo chmod 700 ./auth.sh

# run the cerbot command to generate certificate
sudo certbot certonly --manual --preferred-challenges=dns --manual-auth-hook $authHookPath ----manual-cleanup-hook $cleanupHookPath -d $domain -m $email --agree-tos -n

# convert pem to pfx for keyvault
openssl pkcs12 -export -out $certFileName -inkey $privkeypath -in $fullchainpath -passout pass:__PKPWD__

az keyvault certificate import --vault-name $vaultname --name $cert_name --file $certFileName --password __PKPWD__