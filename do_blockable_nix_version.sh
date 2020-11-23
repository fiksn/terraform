#!/bin/bash
set -euo pipefail

eval "$(jq -r '@sh "HOST=\(.host) TOKEN=\(.token)"')"

# do epic shit

NIX_VERSION="burek"
jq -n --arg nix_version "$NIX_VERSION" \
  '{"nix_version":$nix_version}'
