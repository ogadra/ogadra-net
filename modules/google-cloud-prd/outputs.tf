output "apex_name_servers" {
  description = "Top 3 sorted Cloud DNS name servers of the apex zone."
  value       = local.own_apex_name_servers
}

output "prd_apex_name_servers" {
  description = "Top 3 sorted Cloud DNS name servers of the production subdomain zone."
  value       = local.bunshin_own_apex_name_servers
}

output "tsujiura_apex_name_servers" {
  description = "All sorted Cloud DNS name servers of the Tsujiura zone."
  value = sort([
    for name_server in google_dns_managed_zone.tsujiura.name_servers : trimsuffix(name_server, ".")
  ])
}
