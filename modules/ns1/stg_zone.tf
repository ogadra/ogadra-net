locals {
  stg_ns1_name_servers = split(",", ns1_zone.stg.dns_servers)

  stg_own_apex_name_servers = slice(sort([
    for name_server in local.stg_ns1_name_servers : trimsuffix(name_server, ".")
  ]), 0, 3)

  stg_apex_ns_name_servers = concat(local.stg_own_apex_name_servers, var.stg_peer_apex_name_servers)
}

resource "ns1_zone" "stg" {
  zone                   = var.stg_domain_name
  autogenerate_ns_record = false

  lifecycle {
    postcondition {
      condition     = length(split(",", self.dns_servers)) >= 3
      error_message = "NS1 staging zone must expose at least 3 name servers for apex mirror."
    }
  }
}
