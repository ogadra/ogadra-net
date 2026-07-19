locals {
  domain_name   = "ogadra.net"
  stg_subdomain = "demo"
  prd_subdomain = "bunshin"

  stg_domain_name = "${local.stg_subdomain}.${local.domain_name}"
  prd_domain_name = "${local.prd_subdomain}.${local.domain_name}"

  stg_apex_ns_rrset = concat(module.aws_stg.apex_name_servers, module.ns1.stg_apex_name_servers)
}
