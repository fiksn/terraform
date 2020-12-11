#! /usr/bin/env nix-shell
#! nix-shell -i bash -p bash -p terraform

function finish {
  rm -rf temp.$$
}
trap finish EXIT

cat configuration.nix | sed -E 's/[\$][\{][a-zA-Z0-9_-]+[\}]/.\/burek/g' | sed -E 's@([Ll]ength[ ]*=[ ]*)([.].+);@\1 13;@g' > temp.$$
export NIXOS_CONFIG=$(pwd)/temp.$$
nix-shell test.nix
rm -rf temp.$$
terraform validate
