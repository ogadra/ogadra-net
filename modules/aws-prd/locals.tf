locals {
  tags = {
    ManagedBy  = "Terraform"
    Repository = "ogadra-net"
  }

  own_apex_name_servers = slice(sort([
    for name_server in data.aws_route53_zone.domain.name_servers : trimsuffix(name_server, ".")
  ]), 0, 3)

  prd_regions = toset([
    "asia-northeast1",
    "asia-northeast2",
  ])

  bunshin_own_apex_name_servers = slice(sort([
    for name_server in aws_route53_zone.bunshin.name_servers : trimsuffix(name_server, ".")
  ]), 0, 3)

  prd_aws_apex_addresses = one([
    for address in values(var.prd_aws_records.user_dns.addresses) :
    address.addresses if trimsuffix(address.name, ".") == var.prd_domain_name
  ])

  prd_aws_other_addresses = {
    for key, address in var.prd_aws_records.user_dns.addresses :
    key => address if trimsuffix(address.name, ".") != var.prd_domain_name
  }
}
