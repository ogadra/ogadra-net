output "apex_name_servers" {
  description = "Top 3 sorted NS1 name servers of the apex zone."
  value       = local.own_apex_name_servers
}
