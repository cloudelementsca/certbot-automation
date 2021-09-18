#
# cleanup.sh
#
# Description: This script remove the TXT recoord "_acme-challenge" added in the pre-authentication-hook (godaddy-auth.sh)
#
# Authors:
# - Jack Wen
# - Nicholas Briglio

# API key
key="__dns_provider_key__"
secret="__dns_provider_secret__"

# Authorization header
headers="Authorization: sso-key $key:$secret"

# Domain value from certbot command
domain=$CERTBOT_DOMAIN

# TXT record name and type
txt_name="_acme-challenge"  
record_type="TXT"

# GoDaddy delete API
echo "Delete TXT record with _acme-challenge"
curl -X DELETE "https://api.godaddy.com/v1/domains/$domain/records/$record_type/$txt_name" -H "$headers"

# Search for _acme-challenge, result should show empty array []
echo "Search for _acme-challenge TXT record:"
result=$(curl -s -X GET -H "$headers" "https://api.godaddy.com/v1/domains/$domain/records/$record_type/$txt_name")
echo $result
