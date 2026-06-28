output "name_servers" {
  description = "Route53 name servers for the production subdomain zone."
  value       = aws_route53_zone.bunshin.name_servers
}
