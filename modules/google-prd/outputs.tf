output "name_servers" {
  description = "Cloud DNS name servers for the production subdomain zone."
  value       = google_dns_managed_zone.bunshin.name_servers
}
