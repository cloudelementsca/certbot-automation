#!/bin/bash
#
# godaddy-auth.sh
#
# Description: This script add the TXT recoord "_acme-challenge" with Cerbot generated value.
#
# Authors:
# - Jack Wen
# - Nicholas Briglio

# GoDaddy API key and secret
key="__dns_provider_key__"
secret="__dns_provider_secret__"

headers="Authorization: sso-key $key:$secret"

# record value
txt_value=$CERTBOT_VALIDATION

# domain entered in cerbot command

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

# Add TXT record
echo "Adding TXT record"
curl -X PUT "https://api.godaddy.com/v1/domains/$domain/records/$record_type/$txt_name" -H "accept: application/json" -H "Content-type: application/json" -H "$headers" -d "[ { \"data\": \"$txt_value\", \"name\": \"$txt_name\", \"ttl\": 3600, \"type\": \"$record_type\"} ]"

# sleep in seconds
sleep 120