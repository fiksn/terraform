#! /usr/bin/env nix-shell
#! nix-shell -i bash -p openssh -p jq

set -euo pipefail

# Add steps
eval "$(jq -r '@sh "HOST=\(.host) TOKEN=\(.token) STEPS=\(.steps) PORT=\(.port)"')"

# do epic shit

for i in $(seq 1 $STEPS); do
  RESULT=$(ssh $HOST -o Port=$PORT -o ConnectTimeout=2  -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no "nix-env --version 2>/dev/null | tr -d '\n'" || exit 0)
  if [ -n "$RESULT" ]; then
    break
  fi	
  sleep 2
done

if [ -n "$RESULT" ]; then
  NIX_VERSION="$RESULT"
else
  NIX_VERSION="timeout"
fi

jq -n --arg nix_version "$NIX_VERSION" \
  '{"nix_version":$nix_version}'
