variable "do_token" {}

variable "target_user" {
  type        = string
  description = "SSH user used to connect to the target_host"
  default     = "root"
}

variable "target_port" {
  type        = number
  description = "SSH port used to connect to the target_host"
  default     = 22
}

variable "ssh_private_key" {
  type        = string
  description = "Content of private key used to connect to the target_host"
  default     = ""
}

variable "ssh_private_key_file" {
  type        = string
  description = "Path to private key used to connect to the target_host"
  default     = ""
}

variable "ssh_agent" {
  type        = bool
  description = "Whether to use an SSH agent. True if not ssh_private_key is passed"
  default     = null
}

variable "root_config" {
  description = "Path to private key used to connect to the target_host"
  default     = "./none"

  /*
  validation {
    condition     = substr(var.root_config, 0, 2) == "./"
    error_message = "Root config must start with ./"
  }
  */
}

variable "ssh_key" {
  description = "Name of the ssh key on DigitalOcean"
  default     = "ec"
}

variable "name" {
  description = "Name of the droplet"
  default     = "tf-machine"
}

variable "region" {
  description = "Region where to provision droplet"
  default     = "fra1"
}

variable "size" {
  description = "Size of the droplet"
  default     = "s-1vcpu-1gb"
}

variable "ipv6" {
  description = "Whether you want IPv6 or not"
  default     = true
}

variable "copy_files" {
  description = "Should the local nix files be copied to /etc/nixos on the droplet (experimental!)"
  default     = true
}

variable "triggers" {
  type        = map(string)
  description = "Triggers for deploy"
  default     = {}
}
