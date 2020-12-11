resource "digitalocean_droplet" "tf-machine" {
  image  = "ubuntu-20-04-x64" # tested with ubuntu 20.04
  name   = var.name
  region = var.region
  size   = var.size
  ipv6   = var.ipv6

  ssh_keys = [
    data.digitalocean_ssh_key.key.id
  ]

  user_data = <<EOF
    #cloud-config
      runcmd:
      # digital ocean servers are 67.207.67.3 67.207.67.2
      - sed -i 's/127.0.0.53/8.8.8.8/g' /etc/resolv.conf # Get rid of systemd-resolved stuff
      - curl https://raw.githubusercontent.com/elitak/nixos-infect/master/nixos-infect | PROVIDER=digitalocean NIX_CHANNEL=nixos-20.09 bash 2>&1 | tee /tmp/infect.log
  EOF
}

data "digitalocean_ssh_key" "key" {
  name = var.ssh_key
}

locals {
  nix_config = templatefile("${path.module}/configuration.nix",
    { ssh_key             = data.digitalocean_ssh_key.key.public_key,
      ip4_address         = data.external.do_network.result["ip4_address"],
      ip4_gateway         = data.external.do_network.result["ip4_gateway"],
      ip4_cidr            = data.external.do_network.result["ip4_cidr"],
      ip6_address         = data.external.do_network.result["ip6_address"],
      ip6_gateway         = data.external.do_network.result["ip6_gateway"],
      ip6_cidr            = data.external.do_network.result["ip6_cidr"],
      private_ip4_address = data.external.do_network.result["private_ip4_address"],
      private_ip4_gateway = data.external.do_network.result["private_ip4_gateway"],
      private_ip4_cidr    = data.external.do_network.result["private_ip4_cidr"],
      nix_version         = data.external.do_blockable_nix_version.result["nix_version"],
      root_config         = var.root_config,
      name                = var.name,
  })
}

module "deploy_nixos" {
  source          = "git::https://github.com/tweag/terraform-nixos.git//deploy_nixos?ref=5f5a0408b299874d6a29d1271e9bffeee4c9ca71"
  config          = local.nix_config
  target_host     = digitalocean_droplet.tf-machine.ipv4_address
  build_on_target = true
}

data "external" "do_network" {
  program = ["${path.module}/do_network.sh"]

  query = {
    id    = digitalocean_droplet.tf-machine.id
    token = var.do_token
  }
}

data "external" "do_blockable_nix_version" {
  program = ["${path.module}/do_blockable_nix_version.sh"]

  query = {
    host  = "root@${digitalocean_droplet.tf-machine.ipv4_address}"
    token = var.do_token
    steps = 100
  }
}

resource "null_resource" "copy_nix_files" {
  triggers = {
    nix = module.deploy_nixos.id
  }

  depends_on = [module.deploy_nixos.id]

  provisioner "local-exec" {
    command = "S=root@${digitalocean_droplet.tf-machine.ipv4_address} ; O='-o ConnectTimeout=2 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no' ; SSH=$(eval echo ssh $O); SCP=$(eval echo scp $O); F=./configuration.temp.$$ ; echo '${local.nix_config}' > $F ; $SSH $S 'rm -rf /etc/nixos ; mkdir -p /etc/nixos'; $SCP $F $S:/etc/nixos/configuration.nix ; nix-shell files.nix --arg file $F | grep -v $F | xargs -n 1 -I {} $SSH $S mkdir -p /etc/nixos/$(pathname {} 2>/dev/null) ; nix-shell files.nix --arg file $F | grep -v $F | xargs -n 1 -I {} $SCP {} $S:/etc/nixos/{} ; rm -rf $F"
  }
}

output "id" {
  value       = digitalocean_droplet.tf-machine.id
  description = "The id of the server"
}

output "ip4_address" {
  value       = data.external.do_network.result["ip4_address"]
  description = "The IPv4 address of server"
}

output "ip6_address" {
  value       = data.external.do_network.result["ip6_address"]
  description = "The IPv6 address of server"
}

variable "do_token" {}

variable "root_config" {
  default = "./none"
}

variable "ssh_key" {
  default = "ec"
}

variable "name" {
  default = "tf-machine"
}

variable "region" {
  default = "fra1"
}

variable "size" {
  default = "s-1vcpu-1gb"
}

variable "ipv6" {
  default = true
}

provider "digitalocean" {
  token = var.do_token
}

