locals {
  labels = {
    managed_by = "terraform"
    repository = "ogadra-net"
  }

  zone_name     = replace(var.domain_name, ".", "-")
  prd_zone_name = replace(var.prd_domain_name, ".", "-")

  own_apex_name_servers = slice(sort([
    for name_server in google_dns_managed_zone.domain.name_servers : trimsuffix(name_server, ".")
  ]), 0, 3)

  prd_regions = toset([
    "asia-northeast1",
    "asia-northeast2",
  ])

  bunshin_own_apex_name_servers = slice(sort([
    for name_server in google_dns_managed_zone.bunshin.name_servers : trimsuffix(name_server, ".")
  ]), 0, 3)

  # Cloud DNS probes external endpoints from exactly three source regions and
  # marks an endpoint down only when the majority of them fail.
  prd_health_check_source_regions = [
    "asia-northeast1",
    "asia-southeast1",
    "us-west1",
  ]

  prd_aws_apex_addresses = one([
    for address in values(var.prd_aws_records.user_dns.addresses) :
    address.addresses if trimsuffix(address.name, ".") == var.prd_domain_name
  ])

  prd_aws_other_addresses = {
    for key, address in var.prd_aws_records.user_dns.addresses :
    key => address if trimsuffix(address.name, ".") != var.prd_domain_name
  }
}
