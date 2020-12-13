# Deploy NixOS DigitalOcean

Heavily inspired by [deploy_nixos](https://github.com/tweag/terraform-nixos/tree/master/deploy_nixos#readme).

This Terraform module is able to provision a DigitalOcean droplet and install NixOS on it. It achieves that by provisioning an [Ubuntu](https://ubuntu.com) 20.04 x64 droplet through official digitalocean terraform module and using
[NixOS infect](https://github.com/elitak/nixos-infect) via cloud-init to transform it to [NixOS](https://nixos.org) 20.09. After that it uses [deploy_nixos](https://github.com/tweag/terraform-nixos/tree/master/deploy_nixos#readme) module to 
properly populate the machine. At the end it can also fill /etc/nixos.

## Copy of files

There is some ugly hacking going on to copy all relevant .nix files to the server inside /etc/nixos too. BEWARE
```
nixos-rebuild switch
```
on the server might create a different output (due to different nixpkgs on the server vs. locally). It is still useful to
see what is going on tho.

You can turn that off with "copy_files" variable (by setting it to false).

## Requirements

You need to have Nix installed locally.
