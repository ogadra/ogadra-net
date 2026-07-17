locals {
  tags = {
    ManagedBy  = "Terraform"
    Repository = "ogadra-net"
  }

  own_apex_name_servers = slice(sort([
    for name_server in data.aws_route53_zone.domain.name_servers : trimsuffix(name_server, ".")
  ]), 0, 3)

  apex_ns_name_servers = concat(local.own_apex_name_servers, var.peer_apex_name_servers)
}
