locals {
  prd_ns1_name_servers = split(",", ns1_zone.prd.dns_servers)

  prd_own_apex_name_servers = slice(sort([
    for name_server in local.prd_ns1_name_servers : trimsuffix(name_server, ".")
  ]), 0, 3)

  prd_apex_ns_name_servers = concat(local.prd_own_apex_name_servers, var.prd_peer_apex_name_servers)

  prd_regions = toset([
    "asia-northeast1",
    "asia-northeast2",
  ])

  prd_aws_apex_alias = one([
    for alias in values(var.prd_aws_records.user_dns.aliases) :
    alias if trimsuffix(alias.name, ".") == var.prd_domain_name
  ])

  prd_aws_other_aliases = {
    for key, alias in var.prd_aws_records.user_dns.aliases :
    key => alias if trimsuffix(alias.name, ".") != var.prd_domain_name
  }
}

resource "ns1_zone" "prd" {
  zone                   = var.prd_domain_name
  autogenerate_ns_record = false
  nx_ttl                 = 30

  lifecycle {
    postcondition {
      condition     = length(split(",", self.dns_servers)) >= 3
      error_message = "NS1 production zone must expose at least 3 name servers for apex mirror."
    }
  }
}
