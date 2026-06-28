output "name_servers" {
  description = "Route53 name servers for the production subdomain zone."
  value       = aws_route53_zone.bunshin.name_servers
}

output "acm_validation_records" {
  description = "ACM DNS validation records for the production subdomain."
  value       = local.acm_validation_records
}
