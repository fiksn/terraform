terraform {
  backend "remote" {
    organization = "fiksn"

    workspaces {
      name = "demo"
    }
  }
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "2.2.0"
    }
  }
}

