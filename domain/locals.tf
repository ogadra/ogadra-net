locals {
  domain_name = "ogadra.net"

  google_prd_impersonate_service_account = "${var.impersonate_service_account}@${var.google_prd_project_id}.iam.gserviceaccount.com"

  # Route53 Domains accepts at most 6 name servers.
  selected_aws_domain_name_server_names = slice(sort([
    for name_server in data.aws_route53_zone.domain.name_servers : trimsuffix(name_server, ".")
  ]), 0, 3)
  selected_google_domain_name_server_names = slice(sort([
    for name_server in data.google_dns_managed_zone.domain.name_servers : trimsuffix(name_server, ".")
  ]), 0, 3)

  aws_domain_name_servers = [
    for name_server in local.selected_aws_domain_name_server_names : {
      name     = trimsuffix(name_server, ".")
      glue_ips = []
    }
  ]

  google_domain_name_servers = [
    for name_server in local.selected_google_domain_name_server_names : {
      name     = trimsuffix(name_server, ".")
      glue_ips = []
    }
  ]

  domain_name_servers = concat(local.aws_domain_name_servers, local.google_domain_name_servers)
}
