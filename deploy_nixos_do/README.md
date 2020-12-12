# Deploy NixOS DigitalOcean

Heavily inspired by [deploy_nixos](https://github.com/tweag/terraform-nixos/tree/master/deploy_nixos#readme).

This Terraform module is able to provision a DigitalOcean droplet and install NixOS on it.

## Copy of files

There is some ugly hacking going on to copy all relevant .nix files to the server to /etc/nixos too. BEWARE
```
nixos-rebuild switch
```
on the server might create a different output (due to different nixpkgs on the server vs. locally). It is still useful to
see what is going on tho.

You can turn that off with "copy_files" variable (by setting it to false).
