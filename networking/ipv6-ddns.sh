#!/bin/bash

# store the following sensitive information in $HOME/cloudflare.env file with
# permission of 600

# export API_KEY="your_cloudflare_api_key"
# export EMAIL="your_cloudflare_email"
# export ZONE_ID="your_zone_id"
# export RECORD_NAME="your_record_name"

source $HOME/cloudflare.env 

# Get the current public IPv6 address
IP6=`ip -6 addr show dev eth0 | grep global | awk '{print \$2}' | awk -F "/" '{print \$1}'`

# Get the record ID
RECORD_ID=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records?type=AAAA&name=$RECORD_NAME" \
    -H "X-Auth-Email: $EMAIL" \
    -H "X-Auth-Key: $API_KEY" \
    -H "Content-Type: application/json" | jq -r .result[0].id)

# Update the record
curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$RECORD_ID" \
    -H "X-Auth-Email: $EMAIL" \
    -H "X-Auth-Key: $API_KEY" \
    -H "Content-Type: application/json" \
    --data '{"type":"AAAA","name":"'"$RECORD_NAME"'","content":"'"$IP6"'","ttl":120,"proxied":false}' > /dev/null

echo "Updated IPv6 address to $IP6"