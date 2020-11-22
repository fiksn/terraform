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
      users:
        - name: demo
          ssh-authorized-keys:
            - ${data.digitalocean_ssh_key.ec.public_key}
          sudo: ['ALL=(ALL) NOPASSWD:ALL']
          groups: sudo
          shell: /bin/bash
      runcmd:
      - curl https://raw.githubusercontent.com/elitak/nixos-infect/master/nixos-infect | NO_REBOOT=true PROVIDER=digitalocean NIX_CHANNEL=nixos-20.09 bash 2>&1 | tee /tmp/infect.log
  EOF
}

# curl -X GET -H "Content-Type: application/json" -H "Authorization: Bearer $(echo $DIGITALOCEAN_TOKEN)" "https://api.digitalocean.com/v2/account/keys" | jq .
# curl -X GET -H "Content-Type: application/json" -H "Authorization: Bearer $(echo $TF_VAR_do_toke)" "https://api.digitalocean.com/v2/account/keys" | jq .

data "digitalocean_ssh_key" "ec" {
  name = "ec"
}

/***/
resource "null_resource" "patience" {
    depends_on = [ digitalocean_droplet.tf-machine ]

/*
connection {
    type        = "ssh"
    host        = var.target_host
    port        = var.target_port
    user        = var.target_user
    agent       = var.ssh_agent
    timeout     = "100s"
    private_key = local.ssh_private_key_file != "-" ? file(var.ssh_private_key_file) : null
  }
*/

    provisioner "local-exec" {
      command = "sleep 10"
    }
}


/***/

module "deploy_nixos" {
  source               = "git::https://github.com/tweag/terraform-nixos.git//deploy_nixos?ref=5f5a0408b299874d6a29d1271e9bffeee4c9ca71"
  config               = templatefile("${path.module}/configuration.nix", { key = data.digitalocean_ssh_key.ec.public_key }) 
  target_host          = digitalocean_droplet.tf-machine.ipv4_address
  build_on_target      = true
}


variable "do_token" {}

provider "digitalocean" {
  token = var.do_token
}

