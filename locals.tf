locals {
  domain_name   = "ogadra.net"
  stg_subdomain = "demo"
  prd_subdomain = "bunshin"

  stg_domain_name = "${local.stg_subdomain}.${local.domain_name}"
  prd_domain_name = "${local.prd_subdomain}.${local.domain_name}"

  google_prd_impersonate_service_account = "${var.impersonate_service_account}@${var.google_prd_project_id}.iam.gserviceaccount.com"

  # Route53 Domains accepts at most 6 name servers.
  selected_aws_domain_name_server_names = slice(sort([
    for name_server in data.aws_route53_zone.domain.name_servers : trimsuffix(name_server, ".")
  ]), 0, 3)
  selected_google_domain_name_server_names = slice(sort([
    for name_server in data.google_dns_managed_zone.domain.name_servers : trimsuffix(name_server, ".")
  ]), 0, 3)

  domain_ns_name_servers = concat(
    local.selected_aws_domain_name_server_names,
    local.selected_google_domain_name_server_names,
  )
}
