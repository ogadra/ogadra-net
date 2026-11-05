locals {
  domain_name   = "ogadra.net"
  prd_subdomain = "bunshin"

  prd_domain_name = "${local.prd_subdomain}.${local.domain_name}"

  prd_health_check_path = "/api/health"

  apex_ns_rrset = concat(
    module.aws_prd.apex_name_servers,
    module.google_cloud_prd.apex_name_servers,
  )

  prd_apex_ns_rrset = concat(
    module.aws_prd.prd_apex_name_servers,
    module.google_cloud_prd.prd_apex_name_servers,
  )
}
