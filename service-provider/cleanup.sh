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

domain=$(expr match "$CERTBOT_DOMAIN" '.*\.\(.*\..*\)')

if [ -z "$domain" ];
then
  # top level
  txt_name="_acme-challenge"
  domain=$CERTBOT_DOMAIN
else
  # return the first section
  subdomain=$(expr match $CERTBOT_DOMAIN '\(.*\)\..*\..*')

  # txt name needs to be following the _acme-challenge.test1 pattern, not _acme-challenge.test1.mydomain.com
  txt_name="_acme-challenge.$subdomain"
fi

record_type="TXT"

# GoDaddy delete API
echo "Delete TXT record with _acme-challenge"
curl -X DELETE "https://api.godaddy.com/v1/domains/$domain/records/$record_type/$txt_name" -H "$headers"

# Search for _acme-challenge, result should show empty array []
echo "Search for _acme-challenge TXT record:"
result=$(curl -s -X GET -H "$headers" "https://api.godaddy.com/v1/domains/$domain/records/$record_type/$txt_name")
echo $result
