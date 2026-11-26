output "apex_name_servers" {
  description = "Top 3 sorted Route53 name servers of the apex zone."
  value       = local.own_apex_name_servers
}

output "prd_apex_name_servers" {
  description = "Top 3 sorted Route53 name servers of the production subdomain zone."
  value       = local.bunshin_own_apex_name_servers
}

output "prd_acm_validation_records" {
  description = "Read by the google_cloud_prd module to publish the ACM DNS validation CNAMEs in Cloud DNS."
  value       = local.prd_acm_validation_records
}
