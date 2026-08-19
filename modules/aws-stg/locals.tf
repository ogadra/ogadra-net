locals {
  tags = {
    ManagedBy  = "Terraform"
    Repository = "ogadra-net"
  }

  own_apex_name_servers = slice(sort([
    for name_server in aws_route53_zone.zone.name_servers : trimsuffix(name_server, ".")
  ]), 0, 3)

  apex_ns_name_servers = concat(local.own_apex_name_servers)

  stg_regions = toset([
    "asia-northeast1",
    "asia-northeast2",
  ])

  # The apex alias competes with the Google Cloud GLB via weighted answers;
  # every other alias is an AWS-only name and is registered as-is.
  # Presence of the apex alias is enforced by variable validation.
  stg_aws_apex_alias = one([
    for alias in values(var.stg_aws_records.user_dns.aliases) :
    alias if trimsuffix(alias.name, ".") == var.domain_name
  ])

  stg_aws_other_aliases = {
    for key, alias in var.stg_aws_records.user_dns.aliases :
    key => alias if trimsuffix(alias.name, ".") != var.domain_name
  }
}
