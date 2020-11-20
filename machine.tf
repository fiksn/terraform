resource "digitalocean_droplet" "tf-machine" {
  image  = "ubuntu-20-04-x64"
  name   = "tf-machine"
  region = "nyc1"
  size   = "s-1vcpu-1gb"

  # curl -X GET -H "Content-Type: application/json" -H "Authorization: Bearer $(echo $DIGITALOCEAN_TOKEN)" "https://api.digitalocean.com/v2/account/keys" | jq .
  ssh_keys = [
    24501059
  ]

  user_data = <<EOF
    #cloud-config
      runcmd:
      - curl https://raw.githubusercontent.com/elitak/nixos-infect/master/nixos-infect | PROVIDER=digitalocean NIX_CHANNEL=nixos-20.09 bash 2>&1 | tee /tmp/infect.log
  EOF

  connection {
    host        = self.ipv4_address
    user        = "root"
    type        = "ssh"
    timeout     = "2m"
  }
}

/* 
TODO
 terraform  -var "do_token=${DIGITALOCEAN_TOKEN}" import digitalocean_ssh_key.ec 24501059

resource "digitalocean_ssh_key" "ec" {
  # (resource arguments)
}
*/

module "deploy_nixos" {
  source               = "git::https://github.com/tweag/terraform-nixos.git//deploy_nixos?ref=5f5a0408b299874d6a29d1271e9bffeee4c9ca71"
  nixos_config         = "${path.module}/configuration.nix"
  target_host          = digitalocean_droplet.tf-machine.ipv4_address
}

