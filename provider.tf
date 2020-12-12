terraform {
  backend "remote" {
    organization = "fiksn"

    workspaces {
      name = "demo"
    }
  }

  required_providers {
    digitalocean = {
      version = ">= 2.2.0"
    }
  }
}
