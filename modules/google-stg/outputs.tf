output "name_servers" {
  description = "Cloud DNS name servers for this zone."
  value       = google_dns_managed_zone.zone.name_servers
}
