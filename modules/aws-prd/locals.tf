locals {
  tags = {
    ManagedBy  = "Terraform"
    Repository = "ogadra-net"
  }

  own_apex_name_servers = slice(sort([
    for name_server in data.aws_route53_zone.domain.name_servers : trimsuffix(name_server, ".")
  ]), 0, 3)

  apex_ns_name_servers = concat(local.own_apex_name_servers)

  prd_regions = toset([
    "asia-northeast1",
    "asia-northeast2",
  ])

  bunshin_own_apex_name_servers = slice(sort([
    for name_server in aws_route53_zone.bunshin.name_servers : trimsuffix(name_server, ".")
  ]), 0, 3)

  bunshin_apex_ns_name_servers = concat(local.bunshin_own_apex_name_servers)

  prd_aws_apex_alias = one([
    for alias in values(var.prd_aws_records.user_dns.aliases) :
    alias if trimsuffix(alias.name, ".") == var.prd_domain_name
  ])

  prd_aws_other_aliases = {
    for key, alias in var.prd_aws_records.user_dns.aliases :
    key => alias if trimsuffix(alias.name, ".") != var.prd_domain_name
  }
}
