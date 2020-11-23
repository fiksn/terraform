#!/bin/bash
set -euo pipefail

# requires jq, curl and ipcalc

eval "$(jq -r '@sh "ID=\(.id) TOKEN=\(.token)"')"

function finish {
  rm -rf temp.$$
}
trap finish EXIT

curl -X GET -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" "https://api.digitalocean.com/v2/droplets/$ID" 2>/dev/null > temp.$$ 
IP4_ADDRESS=$(cat temp.$$ | jq '.droplet.networks.v4[] | select(.type=="public") | .ip_address' | tr -d '"')
IP4_NETMASK=$(cat temp.$$ | jq '.droplet.networks.v4[] | select(.type=="public") | .netmask' | tr -d '"')
IP4_GATEWAY=$(cat temp.$$ | jq '.droplet.networks.v4[] | select(.type=="public") | .gateway' | tr -d '"')
IP4_CIDR=$(ipcalc 1.3.3.7 $IP4_NETMASK -b | grep Netmask | cut -d"=" -f 2 | tr -d " \n")

IP6_ADDRESS=$(cat temp.$$ | jq '.droplet.networks.v6[] | select(.type=="public") | .ip_address' | tr -d '"')
IP6_CIDR=$(cat temp.$$ | jq '.droplet.networks.v6[] | select(.type=="public") | .netmask' | tr -d '"')
IP6_GATEWAY=$(cat temp.$$ | jq '.droplet.networks.v6[] | select(.type=="public") | .gateway' | tr -d '"')

rm -rf temp.$$

jq -n --arg ip4_address "$IP4_ADDRESS" --arg ip4_netmask "$IP4_NETMASK" --arg ip4_gateway "$IP4_GATEWAY" --arg ip4_cidr "$IP4_CIDR" --arg ip6_address "$IP6_ADDRESS" --arg ip6_cidr "$IP6_CIDR" --arg ip6_gateway "$IP6_GATEWAY" \
  '{"ip4_address":$ip4_address, "ip4_netmask":$ip4_netmask, "ip4_gateway":$ip4_gateway, "ip4_cidr":$ip4_cidr, "ip6_adress":$ip6_address, "ip6_cidr":$ip6_cidr, "ip6_gateway":$ip6_gateway}'
