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

  prd_aws_apex = one([
    for address in values(var.prd_aws_records.user_dns.addresses) :
    address if trimsuffix(address.name, ".") == var.prd_domain_name
  ])

  prd_aws_apex_a_records    = local.prd_aws_apex.a_records
  prd_aws_apex_aaaa_records = coalesce(local.prd_aws_apex.aaaa_records, [])

  prd_aws_other_addresses = {
    for key, address in var.prd_aws_records.user_dns.addresses :
    key => address if trimsuffix(address.name, ".") != var.prd_domain_name
  }

  prd_acm_validation_records = {
    for domain_name, records in {
      for dvo in setunion(
        aws_acm_certificate.bunshin_apne1.domain_validation_options,
        aws_acm_certificate.bunshin_apne3.domain_validation_options,
        aws_acm_certificate.bunshin_global.domain_validation_options,
      ) :
      trimprefix(dvo.domain_name, "*.") => {
        name = dvo.resource_record_name
        data = dvo.resource_record_value
      }...
    } :
    domain_name => one(distinct(records))
  }
}
