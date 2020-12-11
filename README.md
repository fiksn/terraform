# Terraform

My test repo to play around with [Terraform](https://terraform.io) and [NixOS](https://nixos.org).
Specifically I want to use [DigitalOcean](https://www.digitalocean.com) for running my VMs (called droplets).

You could upload a custom image generated through:
```
nixos-generate -f do
```
however that costs $0.05/GB per month to store.

Therefore I prefer [NixOS infect](https://github.com/elitak/nixos-infect) via cloud-init which transforms an "[Ubuntu](https://ubuntu.com) 20.04 x64" image to
[NixOS](https://nixos.org) 20.09. A little issue is that servers have `systemd-resolved` installed so nixos-infect has some [trouble](https://github.com/elitak/nixos-infect/pull/63) which
I've locally worked-around.

On [https://app.terraform.io](https://app.terraform.io) I have created a new organization and workspace. What is missing from
the [Nix.dev tutorial](https://nix.dev/tutorials/deploying-nixos-using-terraform.html) is that [deploy_nixos](https://github.com/tweag/terraform-nixos/tree/master/deploy_nixos#readme)
terraform module requires you to change "General Settings" and set "Execution Mode" to "Local". (And of course have Nix installed locally, which you can do through
```
curl -L https://nixos.org/nix/install | sh
```
).

## Workflow

```bash
nix-shell
export TF_VAR_do_token=...
export TF_VAR_root_config=./common.nix
terraform init
terraform apply 
```

Keep in mind that configuration.nix is a terraform template (with placeholders for IPs and stuff like that)! Everything else (specified through root_config and possible includes) are regular nix files and it
is recommended to treat root_config as your main configuration.nix (common.nix in the example above).

## Timing

During my testing it usually took around 10 minutes to fully provision a usable NixOS machine this way.

## Copy of files

There is some ugly hacking going on to copy all relevant .nix files to the server to /etc/nixos too. BEWARE
```
nixos-rebuild switch
```
on the server might create a different output (due to different nixpkgs on the server vs. locally). It is still useful to
see what is going on tho.

You can turn that off with "copy_files" variable (by setting it to false).

## References

* [Deploying NixOS using Terraform](https://nix.dev/tutorials/deploying-nixos-using-terraform.html)
* [How To Use Terraform with DigitalOcean](https://www.digitalocean.com/community/tutorials/how-to-use-terraform-with-digitalocean)

Other stuff:

* [NixOS infect](https://github.com/elitak/nixos-infect) 
* [nixos/digital-ocean-image: init (rebase)](https://github.com/NixOS/nixpkgs/pull/66978)
* [nixos-generators - one config, multiple formats](https://github.com/nix-community/nixos-generators)
* [Add a Digital Ocean format](https://github.com/nix-community/nixos-generators/pull/47)
* [Why we use Terraform and not Chef, Puppet, Ansible, SaltStack, or CloudFormation](https://blog.gruntwork.io/why-we-use-terraform-and-not-chef-puppet-ansible-saltstack-or-cloudformation-7989dad2865c)
