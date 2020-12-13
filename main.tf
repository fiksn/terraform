provider "digitalocean" {
  token = var.do_token
}

variable "do_token" {}

module "deploy_nixos_do" {
  #source              = "git::https://github.com/fiksn/terraform.git//deploy_nixos_do?ref=1ffc83d08b653c2c7f47bd4a2241aa6fc8c2d3d6"
  source               = "./deploy_nixos_do"
  do_token             = var.do_token
}
