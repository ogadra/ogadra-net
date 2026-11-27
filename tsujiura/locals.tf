locals {
  domain_name          = "ogadra.net"
  tsujiura_domain_name = "tsujiura.${local.domain_name}"

  tsujiura_ns_rrset = concat(
    sort([for name_server in data.aws_route53_zone.tsujiura.name_servers : trimsuffix(name_server, ".")]),
    sort([for name_server in data.google_dns_managed_zone.tsujiura.name_servers : trimsuffix(name_server, ".")]),
  )
}
