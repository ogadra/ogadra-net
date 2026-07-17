output "name_servers" {
  description = "NS1 name servers for the domain zone."
  value       = split(",", ns1_zone.zone.dns_servers)
}
