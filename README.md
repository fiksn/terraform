# Terraform

My test repo to play around with [Terraform](https://terraform.io) and [NixOS](https://nixos.org).
Specifically I want to use [DigitalOcean](https://www.digitalocean.com) for running my VMs (called droplets).

You could upload a custom image generated through:
```
nixos-generate -f do
```
however that costs $0.05/GB per month to store.

Therefore I prefer [NixOS infect](https://github.com/elitak/nixos-infect) via cloud-init which transforms an "Ubuntu 20.04 x64" image to
[NixOS](https://nixos.org) 20.09.

On [https://app.terraform.io](https://app.terraform.io) I have created a new organization and workspace. What is missing from
the [Nix.dev tutorial](https://nix.dev/tutorials/deploying-nixos-using-terraform.html) is that [deploy_nixos](https://github.com/tweag/terraform-nixos/tree/master/deploy_nixos#readme)
terraform module requires you to change "General Settings" and set "Execution Mode" to "Local". (And of course have Nix installed locally, which you can do through
```
curl -L https://nixos.org/nix/install | sh
```
).

## Workflow

```bash
nix-shell -p ipcalc curl terraform jq # TODO create shell.nix
export TF_VAR_do_token=...
terraform init
terraform apply 
```

## References

* [Deploying NixOS using Terraform](https://nix.dev/tutorials/deploying-nixos-using-terraform.html)
* [How To Use Terraform with DigitalOcean](https://www.digitalocean.com/community/tutorials/how-to-use-terraform-with-digitalocean)

Other stuff:

* [NixOS infect](https://github.com/elitak/nixos-infect) 
* [nixos/digital-ocean-image: init (rebase)](https://github.com/NixOS/nixpkgs/pull/66978)
* [nixos-generators - one config, multiple formats](https://github.com/nix-community/nixos-generators)
* [Add a Digital Ocean format](https://github.com/nix-community/nixos-generators/pull/47)
* [Why we use Terraform and not Chef, Puppet, Ansible, SaltStack, or CloudFormation](https://blog.gruntwork.io/why-we-use-terraform-and-not-chef-puppet-ansible-saltstack-or-cloudformation-7989dad2865c)




