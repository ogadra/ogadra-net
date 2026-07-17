output "name_servers" {
  description = "Route53 name servers for the production subdomain zone."
  value       = aws_route53_zone.bunshin.name_servers
}

output "apex_name_servers" {
  description = "Top 3 sorted Route53 name servers of the apex zone."
  value       = local.own_apex_name_servers
}
