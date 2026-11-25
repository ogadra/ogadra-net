locals {
  domain_name          = "ogadra.net"
  tsujiura_domain_name = "tsujiura.${local.domain_name}"

  common_tags = {
    ManagedBy  = "Terraform"
    Repository = "ogadra-net"
  }

  common_labels = {
    managed_by = "terraform"
    repository = "ogadra-net"
  }

  tsujiura_frontend_a_rrset = concat(
    var.tsujiura_frontend_addresses.global_accelerator,
    [var.tsujiura_frontend_addresses.google_cloud_lb],
  )

  tsujiura_apex_ns_rrset = concat(
    sort([for name_server in aws_route53_zone.tsujiura.name_servers : trimsuffix(name_server, ".")]),
    sort([for name_server in google_dns_managed_zone.tsujiura.name_servers : trimsuffix(name_server, ".")]),
  )
}
