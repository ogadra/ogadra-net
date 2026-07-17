locals {
  domain_name = "ogadra.net"

  ns1_name_servers = split(",", data.ns1_zone.domain.dns_servers)

  # Route53 Domains accepts at most 6 name servers.
  selected_aws_domain_name_server_names = slice(sort([
    for name_server in data.aws_route53_zone.domain.name_servers : trimsuffix(name_server, ".")
  ]), 0, 3)
  selected_ns1_domain_name_server_names = slice(sort([
    for name_server in local.ns1_name_servers : trimsuffix(name_server, ".")
  ]), 0, 3)

  aws_domain_name_servers = [
    for name_server in local.selected_aws_domain_name_server_names : {
      name     = name_server
      glue_ips = []
    }
  ]

  ns1_domain_name_servers = [
    for name_server in local.selected_ns1_domain_name_server_names : {
      name     = name_server
      glue_ips = []
    }
  ]

  domain_name_servers = concat(local.aws_domain_name_servers, local.ns1_domain_name_servers)
}
