output "name_servers" {
  description = "Route53 name servers for this zone."
  value       = aws_route53_zone.zone.name_servers
}

output "acm_validation_records" {
  description = "ACM DNS validation records for this zone."
  value       = local.acm_validation_records
}
