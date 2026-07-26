output "apex_name_servers" {
  description = "Top 3 sorted NS1 name servers of the apex zone."
  value       = local.own_apex_name_servers
}

output "stg_apex_name_servers" {
  description = "Top 3 sorted NS1 name servers of the staging subdomain zone."
  value       = local.stg_own_apex_name_servers
}

output "prd_apex_name_servers" {
  description = "Top 3 sorted NS1 name servers of the production subdomain zone."
  value       = local.prd_own_apex_name_servers
}
