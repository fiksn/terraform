#! /usr/bin/env nix-shell
#! nix-shell -i bash -p jq -p curl -p ipcalc
set -euo pipefail

# requires jq, curl and ipcalc

eval "$(jq -r '@sh "ID=\(.id) TOKEN=\(.token)"')"
FILE="temp.$$"

function finish {
  rm -rf $FILE
}
trap finish EXIT

curl -X GET -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" "https://api.digitalocean.com/v2/droplets/$ID" 2>/dev/null > $FILE

IP4_ADDRESS=$(cat $FILE | jq '.droplet.networks.v4[] | select(.type=="public") | .ip_address' | tr -d '"')
IP4_NETMASK=$(cat $FILE | jq '.droplet.networks.v4[] | select(.type=="public") | .netmask' | tr -d '"')
IP4_GATEWAY=$(cat $FILE | jq '.droplet.networks.v4[] | select(.type=="public") | .gateway' | tr -d '"')
IP4_CIDR=$(ipcalc 1.3.3.7 $IP4_NETMASK -b | grep Netmask | cut -d"=" -f 2 | tr -d " \n")

PRIVATE_IP4_ADDRESS=$(cat $FILE | jq '.droplet.networks.v4[] | select(.type=="private") | .ip_address' | tr -d '"')
PRIVATE_IP4_NETMASK=$(cat $FILE | jq '.droplet.networks.v4[] | select(.type=="private") | .netmask' | tr -d '"')
PRIVATE_IP4_GATEWAY=$(cat $FILE | jq '.droplet.networks.v4[] | select(.type=="private") | .gateway' | tr -d '"')
PRIVATE_IP4_CIDR=$(ipcalc 1.3.3.7 $PRIVATE_IP4_NETMASK -b | grep Netmask | cut -d"=" -f 2 | tr -d " \n")

IP6_ADDRESS=$(cat $FILE | jq '.droplet.networks.v6[] | select(.type=="public") | .ip_address' | tr -d '"')
IP6_CIDR=$(cat $FILE | jq '.droplet.networks.v6[] | select(.type=="public") | .netmask' | tr -d '"')
IP6_GATEWAY=$(cat $FILE | jq '.droplet.networks.v6[] | select(.type=="public") | .gateway' | tr -d '"')

rm -rf $FILE

jq -n --arg ip4_address "$IP4_ADDRESS" --arg ip4_netmask "$IP4_NETMASK" --arg ip4_gateway "$IP4_GATEWAY" --arg ip4_cidr "$IP4_CIDR" \
      --arg ip6_address "$IP6_ADDRESS" --arg ip6_cidr "$IP6_CIDR" --arg ip6_gateway "$IP6_GATEWAY" \
      --arg private_ip4_address "$PRIVATE_IP4_ADDRESS" --arg private_ip4_netmask "$PRIVATE_IP4_NETMASK" --arg private_ip4_gateway "$PRIVATE_IP4_GATEWAY" --arg private_ip4_cidr "$PRIVATE_IP4_CIDR" \
  '{"ip4_address":$ip4_address, "ip4_netmask":$ip4_netmask, "ip4_gateway":$ip4_gateway, "ip4_cidr":$ip4_cidr, "ip6_address":$ip6_address, "ip6_cidr":$ip6_cidr, "ip6_gateway":$ip6_gateway, "private_ip4_address":$private_ip4_address, "private_ip4_netmask":$private_ip4_netmask, "private_ip4_gateway":$private_ip4_gateway, "private_ip4_cidr":$private_ip4_cidr}'

