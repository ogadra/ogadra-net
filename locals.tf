locals {
  domain_name   = "ogadra.net"
  prd_subdomain = "bunshin"

  prd_domain_name = "${local.prd_subdomain}.${local.domain_name}"

  prd_health_check_path = "/api/health"

  prd_apex_ns_rrset = concat(module.aws_prd.prd_apex_name_servers)
}
