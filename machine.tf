resource "digitalocean_droplet" "tf-machine" {
  image  = "ubuntu-20-04-x64"
  name   = "tf-machine"
  region = "fra1"
  size   = "s-1vcpu-1gb"
  ipv6   = true

  ssh_keys = [
    data.digitalocean_ssh_key.ec.id
  ]

  user_data = <<EOF
    #cloud-config
      runcmd:
      - curl https://raw.githubusercontent.com/elitak/nixos-infect/master/nixos-infect | NO_REBOOT=true PROVIDER=digitalocean NIX_CHANNEL=nixos-20.09 bash 2>&1 | tee /tmp/infect.log
  EOF
}

data "digitalocean_ssh_key" "ec" {
  name = "ec"
}

module "deploy_nixos" {
  source = "git::https://github.com/tweag/terraform-nixos.git//deploy_nixos?ref=5f5a0408b299874d6a29d1271e9bffeee4c9ca71"
  config = templatefile("${path.module}/configuration.nix",
    { ssh_key     = data.digitalocean_ssh_key.ec.public_key,
      ip4_address = data.external.do_network.result["ip4_address"],
      ip4_gateway = data.external.do_network.result["ip4_gateway"],
      ip4_cidr    = data.external.do_network.result["ip4_cidr"],
      nix_version = data.external.do_blockable_nix_version.result["nix_version"],
  })
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
    host = "root@${digitalocean_droplet.tf-machine.ipv4_address}"
    token = var.do_token
  }
}

output "ip4_gateway" {
  value       = data.external.do_network.result["ip4_gateway"]
  description = "The IPv4 gateway"
}

variable "do_token" {}

provider "digitalocean" {
  token = var.do_token
}

