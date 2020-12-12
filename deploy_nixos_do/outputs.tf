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
