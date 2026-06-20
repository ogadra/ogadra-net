output "name_servers" {
  description = "Route53 name servers for this zone."
  value       = aws_route53_zone.zone.name_servers
}
