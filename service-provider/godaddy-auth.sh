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
domain=$CERTBOT_DOMAIN

# TXT record name and value
txt_name="_acme-challenge"  
record_type="TXT"

# Add TXT record
echo "Adding TXT record"
curl -X PUT "https://api.godaddy.com/v1/domains/$domain/records/$record_type/$txt_name" -H "accept: application/json" -H "Content-type: application/json" -H "$headers" -d "[ { \"data\": \"$txt_value\", \"name\": \"$txt_name\", \"ttl\": 3600, \"type\": \"$record_type\"} ]"

# sleep in seconds
sleep 120